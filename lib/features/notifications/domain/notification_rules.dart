import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// When the scheduled notifications fire (S07 "Sunday evenings").
const int weeklySummaryWeekday = DateTime.sunday;
const int weeklySummaryMinutes = 19 * 60;
const int periodStartedMinutes = 9 * 60;

/// Something worth a notification (PRD §5.4), before it's put into words.
/// [at] is when it happened, which becomes the inbox row's time.
sealed class NotificationEvent {
  const new(this.at);

  final DateTime at;

  /// The category it's about, for the inbox tile. Null for the monthly
  /// budget and the scheduled kinds.
  int? get categoryId => null;

  NotificationKind get kind;
}

/// A limit, or the monthly budget when [category] is null, reached 80%.
final class BudgetWarning extends NotificationEvent {
  const new({
    required this.category,
    required this.categoryId,
    required this.percent,
    required this.leftMinor,
    required this.daysLeft,
    required DateTime at,
  }) : super(at);

  final String? category;
  @override
  final int? categoryId;
  final int percent;
  final int leftMinor;
  final int daysLeft;

  @override
  NotificationKind get kind => NotificationKind.budgetWarning;
}

/// A limit, or the monthly budget when [category] is null, reached 100%.
final class OverBudget extends NotificationEvent {
  const new({
    required this.category,
    required this.categoryId,
    required this.spentMinor,
    required this.limitMinor,
    required DateTime at,
  }) : super(at);

  final String? category;
  @override
  final int? categoryId;
  final int spentMinor;
  final int limitMinor;

  @override
  NotificationKind get kind => NotificationKind.overBudget;
}

final class IncomeRecorded extends NotificationEvent {
  const new({
    required this.category,
    required this.categoryId,
    required this.amountMinor,
    required DateTime at,
  }) : super(at);

  final String category;
  @override
  final int categoryId;
  final int amountMinor;

  @override
  NotificationKind get kind => NotificationKind.incomeRecorded;
}

final class DailyReminder extends NotificationEvent {
  const new(super.at);

  @override
  NotificationKind get kind => NotificationKind.dailyReminder;
}

/// Spending in the 7 days ending on the summary's Sunday, and the 7
/// before.
final class WeeklySummary extends NotificationEvent {
  const new({
    required this.lastWeekMinor,
    required this.weekBeforeMinor,
    required DateTime at,
  }) : super(at);

  final int lastWeekMinor;
  final int weekBeforeMinor;

  @override
  NotificationKind get kind => NotificationKind.weeklySummary;
}

final class PeriodStarted extends NotificationEvent {
  const new({
    required this.period,
    required this.budgetMinor,
    required DateTime at,
  }) : super(at);

  final Period period;
  final int? budgetMinor;

  @override
  NotificationKind get kind => NotificationKind.periodStarted;
}

/// What a change to the transactions, from [before] to [after], is worth
/// telling: a limit or the budget crossing 80% or 100% this period (when
/// budget alerts are on), and each new income transaction. Only an upward
/// crossing counts, so later edits above a threshold stay quiet. Jumping
/// straight past 100% gives only the over-budget alert.
List<NotificationEvent> transactionEvents({
  required Iterable<Transaction> before,
  required Iterable<Transaction> after,
  required Iterable<Category> categories,
  required Preferences prefs,
  required DateTime now,
}) {
  final period = periodFor(now, prefs.monthStartDay);
  final days = daysLeft(period, now);
  final events = <NotificationEvent>[];

  NotificationEvent? crossing(
    Category? category,
    int was,
    int spent,
    int limit,
  ) {
    final from = budgetStatus(spentMinor: was, limitMinor: limit);
    final to = budgetStatus(spentMinor: spent, limitMinor: limit);
    if (to == from) return null;
    return switch (to) {
      BudgetStatus.negative => OverBudget(
        category: category?.name,
        categoryId: category?.id,
        spentMinor: spent,
        limitMinor: limit,
        at: now,
      ),
      BudgetStatus.warning when from != BudgetStatus.negative => BudgetWarning(
        category: category?.name,
        categoryId: category?.id,
        percent: usedPercent(spentMinor: spent, limitMinor: limit)!,
        leftMinor: limit - spent,
        daysLeft: days,
        at: now,
      ),
      _ => null,
    };
  }

  if (prefs.budgetAlertsOn) {
    if (prefs.monthlyBudgetMinor case final budget?) {
      final event = crossing(
        null,
        periodTotals(before, period).spentMinor,
        periodTotals(after, period).spentMinor,
        budget,
      );
      if (event != null) events.add(event);
    }
    final wasByCategory = spentByCategory(before, period);
    final byCategory = spentByCategory(after, period);
    for (final c in categories) {
      final limit = c.limitMinor;
      if (limit == null || c.type != TransactionType.expense) continue;
      final event = crossing(
        c,
        wasByCategory[c.id] ?? 0,
        byCategory[c.id] ?? 0,
        limit,
      );
      if (event != null) events.add(event);
    }
  }

  final known = {for (final t in before) t.id};
  final names = {for (final c in categories) c.id: c.name};
  for (final t in after) {
    if (t.type != TransactionType.income || known.contains(t.id)) continue;
    events.add(
      IncomeRecorded(
        category: names[t.categoryId] ?? '',
        categoryId: t.categoryId,
        amountMinor: t.amountMinor,
        at: now,
      ),
    );
  }
  return events;
}

/// The scheduled notifications that fired after [from] and up to [to],
/// for the inbox: the latest daily reminder, weekly summary and period
/// start in that span, at most one of each, oldest first. Times are local.
List<NotificationEvent> scheduledEvents({
  required DateTime from,
  required DateTime to,
  required Preferences prefs,
  required Iterable<Transaction> transactions,
}) {
  final events = <NotificationEvent>[];
  bool fired(DateTime at) => at.isAfter(from) && !at.isAfter(to);
  final local = to.toLocal();
  final today = DateTime(local.year, local.month, local.day);

  if (prefs.dailyReminderOn) {
    var at = _at(today, prefs.dailyReminderMinutes);
    if (at.isAfter(local)) {
      at = _at(_addDays(today, -1), prefs.dailyReminderMinutes);
    }
    if (fired(at)) events.add(DailyReminder(at));
  }

  if (prefs.weeklySummaryOn) {
    final back = (today.weekday - weeklySummaryWeekday) % 7;
    var sunday = _addDays(today, -back);
    if (_at(sunday, weeklySummaryMinutes).isAfter(local)) {
      sunday = _addDays(sunday, -7);
    }
    final at = _at(sunday, weeklySummaryMinutes);
    if (fired(at)) {
      int spent(DateTime first) => periodTotals(transactions, (
        start: first,
        end: _addDays(first, 6),
      )).spentMinor;
      events.add(
        WeeklySummary(
          lastWeekMinor: spent(_addDays(sunday, -6)),
          weekBeforeMinor: spent(_addDays(sunday, -13)),
          at: at,
        ),
      );
    }
  }

  var period = periodFor(today, prefs.monthStartDay);
  if (_at(period.start, periodStartedMinutes).isAfter(local)) {
    period = periodFor(_addDays(period.start, -1), prefs.monthStartDay);
  }
  final started = _at(period.start, periodStartedMinutes);
  if (fired(started)) {
    events.add(
      PeriodStarted(
        period: period,
        budgetMinor: prefs.monthlyBudgetMinor,
        at: started,
      ),
    );
  }

  return events..sort((a, b) => a.at.compareTo(b.at));
}

/// When the next period starts, at the time its notification fires.
DateTime nextPeriodStart(DateTime now, MonthStartDay startDay) {
  final end = periodFor(now, startDay).end;
  return _at(_addDays(end, 1), periodStartedMinutes);
}

DateTime _addDays(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day + days);

DateTime _at(DateTime day, int minutes) =>
    DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
