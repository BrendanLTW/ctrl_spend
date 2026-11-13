import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_repository.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_rules.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_text.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// Keeps notifications in step with the app (PRD §5.4), once onboarding is
/// done:
/// - registers the daily reminder, weekly summary and next period start
///   with the phone, again whenever a setting they depend on changes;
/// - on launch and on resume, writes inbox rows for the ones that fired
///   since the last check, since the phone can't run our code when they
///   fire;
/// - writes budget alerts and income rows as transactions change.
class NotificationService {
  new(this._ref) {
    _ref
      ..listen(
        preferencesProvider,
        (_, next) => _onPreferences(next.value),
        fireImmediately: true,
      )
      ..listen(categoriesProvider(), (_, next) {
        if (next.value case final categories?) _categories = categories;
      }, fireImmediately: true)
      ..listen(
        transactionsProvider(),
        (_, next) => _onTransactions(next.value),
        fireImmediately: true,
      );
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(catchUp()));
  }

  static const dailyId = 1;
  static const weeklyId = 2;
  static const periodId = 3;

  final Ref _ref;
  late final AppLifecycleListener _lifecycle;
  final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));
  static const _locale = 'en';

  Preferences? _prefs;
  List<Category> _categories = const [];
  List<Transaction>? _transactions;
  Object? _scheduled;
  bool _caughtUpOnLaunch = false;
  Future<void>? _catchingUp;

  bool get _active => _prefs?.onboardingComplete ?? false;

  DateTime _now() => _ref.read(clockProvider)();

  MoneyFormatter get _formatter =>
      MoneyFormatter(Currency.fromCode(_prefs?.currencyCode ?? ''));

  /// S07's "Turn on notifications": asks the phone, then schedules.
  Future<bool> requestPermission() async {
    final granted = await _ref
        .read(notificationSchedulerProvider)
        .requestPermission();
    _scheduled = null;
    await _schedule();
    return granted;
  }

  /// Writes inbox rows for scheduled notifications that fired since the
  /// last check. The first check only starts the clock.
  Future<void> catchUp() => _catchingUp ??= () async {
    try {
      final prefs = _prefs;
      final transactions = _transactions;
      // Runs again once both have loaded (see _catchUpOnLaunch).
      if (prefs == null || !prefs.onboardingComplete || transactions == null) {
        return;
      }
      final now = _now();
      if (prefs.notificationsCheckedAt case final checked?) {
        for (final event in scheduledEvents(
          from: checked.toLocal(),
          to: now,
          prefs: prefs,
          transactions: transactions,
        )) {
          await _write(event);
        }
      }
      await _ref
          .read(preferencesRepositoryProvider)
          .update((p) => p.copyWith(notificationsCheckedAt: now));
      await _schedule();
    } finally {
      _catchingUp = null;
    }
  }();

  /// After Delete all data: cancels what's scheduled with the phone and
  /// forgets it, so finishing onboarding again schedules from scratch.
  Future<void> reset() async {
    _scheduled = null;
    _caughtUpOnLaunch = false;
    // Forget the old settings too: otherwise a transactions update that
    // arrives before the reset settings would catch up as if onboarded.
    _prefs = null;
    final scheduler = _ref.read(notificationSchedulerProvider);
    for (final id in const [dailyId, weeklyId, periodId]) {
      await scheduler.cancel(id);
    }
  }

  void dispose() => _lifecycle.dispose();

  void _onPreferences(Preferences? prefs) {
    if (prefs == null) return;
    _prefs = prefs;
    if (!_active) return;
    if (!_catchUpOnLaunch()) unawaited(_schedule());
  }

  /// Starts the first catch-up once settings and transactions have both
  /// loaded. True only when it starts it (it schedules too).
  bool _catchUpOnLaunch() {
    if (_caughtUpOnLaunch || !_active || _transactions == null) return false;
    _caughtUpOnLaunch = true;
    unawaited(catchUp());
    return true;
  }

  void _onTransactions(List<Transaction>? transactions) {
    if (transactions == null) return;
    final before = _transactions;
    _transactions = transactions;
    _catchUpOnLaunch();
    final prefs = _prefs;
    if (before == null || prefs == null || !_active) return;
    for (final event in transactionEvents(
      before: before,
      after: transactions,
      categories: _categories,
      prefs: prefs,
      now: _now(),
    )) {
      unawaited(_write(event));
    }
  }

  Future<void> _write(NotificationEvent event) {
    final text = notificationText(event, _l10n, _formatter, _locale);
    return _ref
        .read(notificationRepositoryProvider)
        .add(
          kind: event.kind,
          title: text.title,
          body: text.body,
          createdAt: event.at,
          categoryId: event.categoryId,
        );
  }

  /// Registers what the phone should show, when anything it depends on
  /// has changed since last time.
  Future<void> _schedule() async {
    final prefs = _prefs;
    if (prefs == null || !_active) return;
    final nextStart = nextPeriodStart(_now(), prefs.monthStartDay);
    final key = (
      prefs.dailyReminderOn,
      prefs.dailyReminderMinutes,
      prefs.weeklySummaryOn,
      prefs.monthlyBudgetMinor,
      prefs.currencyCode,
      nextStart,
    );
    if (key == _scheduled) return;
    _scheduled = key;

    final scheduler = _ref.read(notificationSchedulerProvider);
    await scheduler.cancel(dailyId);
    if (prefs.dailyReminderOn) {
      await scheduler.scheduleDaily(
        id: dailyId,
        minutes: prefs.dailyReminderMinutes,
        title: _l10n.notifyDailyTitle,
        body: _l10n.notifyDailyBody,
      );
    }
    await scheduler.cancel(weeklyId);
    if (prefs.weeklySummaryOn) {
      await scheduler.scheduleWeekly(
        id: weeklyId,
        weekday: weeklySummaryWeekday,
        minutes: weeklySummaryMinutes,
        title: _l10n.notifyWeeklyReadyTitle,
        body: _l10n.notifyWeeklyReadyBody,
      );
    }
    await scheduler.cancel(periodId);
    final text = notificationText(
      PeriodStarted(
        period: periodFor(nextStart, prefs.monthStartDay),
        budgetMinor: prefs.monthlyBudgetMinor,
        at: nextStart,
      ),
      _l10n,
      _formatter,
      _locale,
    );
    await scheduler.scheduleOnce(
      id: periodId,
      at: nextStart,
      title: text.title,
      body: text.body,
    );
  }
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final service = NotificationService(ref);
  ref.onDispose(service.dispose);
  return service;
}
