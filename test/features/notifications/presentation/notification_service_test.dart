import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_service.dart';
import 'package:ctrl_spend/features/onboarding/presentation/all_set_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_notification_repository.dart';
import '../../../helpers/fake_notification_scheduler.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fake_transaction_repository.dart';

/// Moved by tests to stand for time passing.
late DateTime now;

late FakePreferencesRepository prefs;
late FakeCategoryRepository categories;
late FakeTransactionRepository transactions;
late FakeNotificationRepository inbox;
late FakeNotificationScheduler scheduler;
late ProviderContainer container;

const onboarded = Preferences(
  onboardingComplete: true,
  monthStartDay: DayOfMonth(15),
  monthlyBudgetMinor: 200000,
);

Future<void> pumpApp(
  WidgetTester tester, {
  Preferences initial = onboarded,
  Future<void> Function()? seed,
}) async {
  now = DateTime(2026, 11, 4, 9);
  prefs = FakePreferencesRepository(initial);
  categories = FakeCategoryRepository();
  transactions = FakeTransactionRepository();
  inbox = FakeNotificationRepository();
  scheduler = FakeNotificationScheduler();
  await seed?.call();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: prefs,
        categories: categories,
        transactions: transactions,
        notifications: inbox,
        scheduler: scheduler,
      ),
      clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
}

Future<void> spend(
  WidgetTester tester,
  int minor,
  String category, {
  String title = 'x',
}) async {
  await transactions.add(
    amountMinor: minor,
    type: category == 'Salary'
        ? TransactionType.income
        : TransactionType.expense,
    categoryId: categories.byName(category).id,
    occurredAt: DateTime(2026, 11, 3, 12),
    title: title,
  );
  await tester.pumpAndSettle();
}

List<String> titles() => [for (final n in inbox.all) n.title];

void main() {
  group('scheduling', () {
    testWidgets('the first launch schedules and starts the clock', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(inbox.all, isEmpty);
      expect((await prefs.read()).notificationsCheckedAt, now);
      final daily = scheduler.pending[NotificationService.dailyId]!;
      expect(daily.kind, 'daily');
      expect(daily.minutes, 21 * 60);
      expect(daily.title, "Log today's spending?");
      expect(scheduler.pending[NotificationService.weeklyId], isNull);
      final period = scheduler.pending[NotificationService.periodId]!;
      expect(period.at, DateTime(2026, 11, 15, 9));
      expect(period.title, 'New period started');
      expect(period.body, 'Your RM 2,000 budget has reset.');
    });

    testWidgets('settings changes reschedule', (tester) async {
      await pumpApp(tester);
      await prefs.update(
        (p) => p.copyWith(
          dailyReminderOn: false,
          weeklySummaryOn: true,
          monthStartDay: const DayOfMonth(1),
        ),
      );
      await tester.pumpAndSettle();
      expect(scheduler.pending[NotificationService.dailyId], isNull);
      final weekly = scheduler.pending[NotificationService.weeklyId]!;
      expect(weekly.weekday, DateTime.sunday);
      expect(weekly.minutes, 19 * 60);
      expect(weekly.title, 'Your weekly summary is ready');
      expect(
        scheduler.pending[NotificationService.periodId]!.at,
        DateTime(2026, 12, 1, 9),
      );
    });

    testWidgets('nothing happens before onboarding is done', (tester) async {
      await pumpApp(tester, initial: const Preferences());
      expect(scheduler.pending, isEmpty);
      expect((await prefs.read()).notificationsCheckedAt, isNull);
    });
  });

  group('catch-up', () {
    testWidgets('writes rows for what fired since the last check', (
      tester,
    ) async {
      await pumpApp(
        tester,
        initial: onboarded.copyWith(
          notificationsCheckedAt: DateTime(2026, 11, 3, 20),
        ),
      );
      final reminder = inbox.all.single;
      expect(reminder.kind, NotificationKind.dailyReminder);
      expect(reminder.title, "Log today's spending?");
      expect(reminder.body, 'Take a moment to add what you spent today.');
      expect(reminder.createdAt, DateTime(2026, 11, 3, 21));
      expect(reminder.readAt, isNull);
      expect((await prefs.read()).notificationsCheckedAt, now);
    });

    testWidgets('resuming the app checks again', (tester) async {
      await pumpApp(tester);
      now = DateTime(2026, 11, 15, 22);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(titles(), ['New period started', "Log today's spending?"]);
      expect(inbox.all.first.body, 'Your RM 2,000 budget has reset.');
      // The next period's start is registered after the roll-over.
      expect(
        scheduler.pending[NotificationService.periodId]!.at,
        DateTime(2026, 12, 15, 9),
      );
    });
  });

  group('transactions', () {
    testWidgets('a limit crossing 80% writes the PRD copy', (tester) async {
      await pumpApp(
        tester,
        seed: () => categories.update(
          categories.byName('Food').copyWith(limitMinor: 40000),
        ),
      );
      await spend(tester, 30000, 'Food');
      expect(inbox.all, isEmpty);
      await spend(tester, 2800, 'Food');
      final alert = inbox.all.single;
      expect(alert.kind, NotificationKind.budgetWarning);
      expect(alert.title, 'Food is at 82% of its limit');
      expect(alert.body, 'RM 72 left with 10 days to go.');
      expect(alert.createdAt, now);
    });

    testWidgets('going over a limit writes the PRD copy', (tester) async {
      await pumpApp(
        tester,
        seed: () => categories.update(
          categories.byName('Shopping').copyWith(limitMinor: 20000),
        ),
      );
      await spend(tester, 21000, 'Shopping');
      expect(titles(), ['Shopping is over budget']);
      expect(
        inbox.all.single.body,
        "You've spent RM 210 of your RM 200 limit.",
      );
    });

    testWidgets('the monthly budget alerts too', (tester) async {
      await pumpApp(tester);
      await spend(tester, 201000, 'Bills');
      expect(titles(), ["You're over budget"]);
      expect(
        inbox.all.single.body,
        "You've spent RM 2,010 of your RM 2,000 budget.",
      );
    });

    testWidgets('alerts follow the Budget alerts setting', (tester) async {
      await pumpApp(tester, initial: onboarded.copyWith(budgetAlertsOn: false));
      await spend(tester, 201000, 'Bills');
      expect(inbox.all, isEmpty);
    });

    testWidgets('income is recorded', (tester) async {
      await pumpApp(tester);
      await spend(tester, 480000, 'Salary', title: 'November pay');
      expect(titles(), ['Salary added']);
      expect(inbox.all.single.body, '+RM 4,800.00 · November pay');
    });
  });

  testWidgets('S07 Turn on notifications asks, then moves on', (tester) async {
    await pumpApp(
      tester,
      initial: const Preferences(userName: 'Alex', monthlyBudgetMinor: 200000),
    );
    unawaited(
      container.read(appRouterProvider).push(Routes.onboardingReminders),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn on notifications'));
    await tester.pumpAndSettle();
    expect(scheduler.permissionRequests, 1);
    expect(find.byType(AllSetScreen), findsOneWidget);
  });
}
