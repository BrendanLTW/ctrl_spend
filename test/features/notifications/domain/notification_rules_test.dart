import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_rules.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 1;

Transaction tx(
  int amountMinor, {
  int categoryId = food,
  TransactionType type = TransactionType.expense,
  DateTime? at,
  String title = 'x',
}) => Transaction(
  id: _nextId++,
  amountMinor: amountMinor,
  type: type,
  categoryId: categoryId,
  occurredAt: (at ?? DateTime(2026, 11, 2, 12)).toUtc(),
  title: title,
);

const food = 1;
const salary = 7;

final categories = [
  const Category(
    id: food,
    name: 'Food',
    type: TransactionType.expense,
    iconKey: CategoryIconKey.food,
    colorKey: CategoryColorKey.orange,
    sortOrder: 1,
    limitMinor: 40000,
  ),
  const Category(
    id: salary,
    name: 'Salary',
    type: TransactionType.income,
    iconKey: CategoryIconKey.wallet,
    colorKey: CategoryColorKey.green,
    sortOrder: 7,
  ),
];

/// 4 Nov 2026, 9:00, a Wednesday; the period is 15 Oct – 14 Nov.
final now = DateTime(2026, 11, 4, 9);
const prefs = Preferences(
  monthStartDay: DayOfMonth(15),
  monthlyBudgetMinor: 200000,
);

List<NotificationEvent> events(
  List<Transaction> before,
  List<Transaction> added, {
  Preferences settings = prefs,
}) => transactionEvents(
  before: before,
  after: [...before, ...added],
  categories: categories,
  prefs: settings,
  now: now,
);

void main() {
  group('transactionEvents', () {
    test('a limit crossing 80% warns with what is left', () {
      final result = events([tx(30000)], [tx(2800)]);
      final warning = result.single as BudgetWarning;
      expect(warning.category, 'Food');
      expect(warning.percent, 82);
      expect(warning.leftMinor, 7200);
      expect(warning.daysLeft, 10);
      expect(warning.at, now);
    });

    test('below 80% or staying above it is quiet', () {
      expect(events([], [tx(31999)]), isEmpty);
      expect(events([tx(33000)], [tx(1000)]), isEmpty);
    });

    test('crossing 100% is over budget, even straight from below', () {
      final over = events([tx(10000)], [tx(31000)]).single as OverBudget;
      expect(over.category, 'Food');
      expect(over.spentMinor, 41000);
      expect(over.limitMinor, 40000);
      // Exactly at the limit counts as over (the shared thresholds).
      expect(events([tx(39000)], [tx(1000)]).single, isA<OverBudget>());
    });

    test('the monthly budget gets its own alerts', () {
      final result = events(
        [tx(150000, categoryId: 2)],
        [tx(10000, categoryId: 2)],
      );
      final warning = result.single as BudgetWarning;
      expect(warning.category, isNull);
      expect(warning.percent, 80);
      expect(warning.leftMinor, 40000);
    });

    test('other periods and income do not count toward budgets', () {
      expect(events([], [tx(39000, at: DateTime(2026, 10, 14))]), isEmpty);
    });

    test('budget alerts can be turned off', () {
      expect(
        events(
          [tx(30000)],
          [tx(20000)],
          settings: prefs.copyWith(budgetAlertsOn: false),
        ),
        isEmpty,
      );
    });

    test('each new income transaction is recorded', () {
      final pay = tx(
        480000,
        categoryId: salary,
        type: TransactionType.income,
        title: 'November pay',
      );
      final income = events([], [pay]).single as IncomeRecorded;
      expect(income.category, 'Salary');
      expect(income.categoryId, salary);
      expect(income.amountMinor, 480000);
      // Already known: an edit, not a new one.
      expect(events([pay], []), isEmpty);
    });
  });

  group('scheduledEvents', () {
    List<NotificationEvent> due(
      DateTime from,
      DateTime to, {
      Preferences settings = prefs,
      List<Transaction> transactions = const [],
    }) => scheduledEvents(
      from: from,
      to: to,
      prefs: settings,
      transactions: transactions,
    );

    test('the daily reminder that fired since the last check', () {
      final result = due(DateTime(2026, 11, 3, 20), DateTime(2026, 11, 4, 9));
      expect(result.single, isA<DailyReminder>());
      expect(result.single.at, DateTime(2026, 11, 3, 21));
    });

    test('only the latest reminder after a long absence', () {
      final result = due(DateTime(2026, 10, 20), DateTime(2026, 11, 4, 22));
      final reminders = result.whereType<DailyReminder>();
      expect(reminders.single.at, DateTime(2026, 11, 4, 21));
    });

    test('nothing before it fires, or when it is off', () {
      expect(due(DateTime(2026, 11, 4, 8), DateTime(2026, 11, 4, 20)), isEmpty);
      expect(
        due(
          DateTime(2026, 11, 3, 20),
          DateTime(2026, 11, 4, 9),
          settings: prefs.copyWith(dailyReminderOn: false),
        ),
        isEmpty,
      );
    });

    test('the weekly summary compares last week with the one before', () {
      // Sunday 1 Nov, 19:00. Last week is Mon 26 Oct – Sun 1 Nov.
      final result = due(
        DateTime(2026, 11, 1, 18),
        DateTime(2026, 11, 1, 20),
        settings: prefs.copyWith(dailyReminderOn: false, weeklySummaryOn: true),
        transactions: [
          tx(29800, at: DateTime(2026, 10, 30, 12)),
          tx(33900, at: DateTime(2026, 10, 20, 12)),
          tx(5000, at: DateTime(2026, 11, 2, 12)),
          tx(9999, type: TransactionType.income, at: DateTime(2026, 10, 28)),
        ],
      );
      final summary = result.single as WeeklySummary;
      expect(summary.at, DateTime(2026, 11, 1, 19));
      expect(summary.lastWeekMinor, 29800);
      expect(summary.weekBeforeMinor, 33900);
    });

    test('the weekly summary is off by default', () {
      expect(
        due(DateTime(2026, 11, 1, 18), DateTime(2026, 11, 1, 20)),
        isEmpty,
      );
    });

    test('a new period started at 9:00 on its first day', () {
      final result = due(
        DateTime(2026, 11, 14, 22),
        DateTime(2026, 11, 15, 10),
        settings: prefs.copyWith(dailyReminderOn: false),
      );
      final started = result.single as PeriodStarted;
      expect(started.at, DateTime(2026, 11, 15, 9));
      expect(started.period.start, DateTime(2026, 11, 15));
      expect(started.budgetMinor, 200000);
    });

    test('several kinds come back oldest first', () {
      final result = due(
        DateTime(2026, 11, 14, 22),
        DateTime(2026, 11, 15, 22),
        settings: prefs.copyWith(weeklySummaryOn: true),
      );
      expect(result.map((e) => e.runtimeType), [
        PeriodStarted,
        WeeklySummary,
        DailyReminder,
      ]);
    });
  });

  test('nextPeriodStart is 9:00 on the day after the period ends', () {
    expect(
      nextPeriodStart(now, const DayOfMonth(15)),
      DateTime(2026, 11, 15, 9),
    );
    expect(
      nextPeriodStart(DateTime(2028, 2, 10), const LastDayOfMonth()),
      DateTime(2028, 2, 29, 9),
    );
  });
}
