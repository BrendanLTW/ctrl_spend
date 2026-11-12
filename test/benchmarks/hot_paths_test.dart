import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/activity/domain/day_groups.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/default_categories.dart';
import 'package:ctrl_spend/features/dev/domain/sample_data.dart';
import 'package:ctrl_spend/features/insights/domain/insight_calculations.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_rules.dart';
import 'package:ctrl_spend/features/periods/domain/period_summary.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

/// What screens compute over every transaction when data changes, timed
/// with the 5,000-transaction sample (task 4.3, PRD §10). The bound only
/// catches a blow-up (say, quadratic work); the printed medians are the
/// numbers in docs/quality-audit.md. Device timings come from
/// integration_test/performance_test.dart.
void main() {
  final today = DateTime(2026, 11, 4, 9);
  const startDay = DayOfMonth(15);
  const prefs = Preferences(
    onboardingComplete: true,
    monthStartDay: startDay,
    monthlyBudgetMinor: 200000,
  );
  final categories = [
    for (final (i, c) in defaultCategories.indexed)
      Category(
        id: i + 1,
        name: c.name,
        type: c.type,
        iconKey: c.icon,
        colorKey: c.colour,
        sortOrder: i,
        limitMinor: c.type == TransactionType.expense ? 40000 : null,
      ),
  ];
  final ids = {for (final c in categories) c.name: c.id};
  final transactions = [
    for (final (i, r) in sampleTransactions(today: today).indexed)
      Transaction(
        id: i + 1,
        amountMinor: r.amountMinor,
        type: r.type,
        categoryId: ids[r.category]!,
        occurredAt: r.occurredAt.toUtc(),
        title: r.title,
        note: r.note,
      ),
  ].reversed.toList();
  final period = periodFor(today, startDay);

  /// Median of 21 runs, in milliseconds, after a warm-up.
  double time(void Function() work) {
    work();
    final runs = <double>[];
    for (var i = 0; i < 21; i++) {
      final watch = Stopwatch()..start();
      work();
      runs.add(watch.elapsedMicroseconds / 1000);
    }
    return (runs..sort())[10];
  }

  final cases = <String, void Function()>{
    'Activity: group by day': () => groupByDay(transactions),
    'S18: category shares': () => categoryShares(transactions, period),
    'S19: last seven days': () => lastSevenDays(
      transactions,
      today: today,
      startDay: startDay,
      budgetMinor: 200000,
    ),
    'S20: six periods': () => recentPeriods(
      transactions,
      today: today,
      startDay: startDay,
      budgetMinor: 200000,
    ),
    'S25: twelve previous periods': () {
      final byPeriod = transactionsByPeriod(transactions, startDay);
      for (final p in previousPeriods(
        today: today,
        startDay: startDay,
        since: transactions.last.occurredAt,
      )) {
        periodSummary(
          byPeriod[p.start] ?? const [],
          period: p,
          categories: categories,
          budgetMinor: 200000,
        );
      }
    },
    'Notifications: diff after a save': () => transactionEvents(
      before: transactions.skip(1),
      after: transactions,
      categories: categories,
      prefs: prefs,
      now: today,
    ),
    'Notifications: catch-up': () => scheduledEvents(
      from: today.subtract(const Duration(days: 30)),
      to: today,
      prefs: prefs.copyWith(weeklySummaryOn: true),
      transactions: transactions,
    ),
  };

  for (final MapEntry(key: name, value: work) in cases.entries) {
    test('$name stays fast with 5,000 transactions', () {
      final ms = time(work);
      // The numbers are the point of the test.
      // ignore: avoid_print
      print('$name: ${ms.toStringAsFixed(2)} ms');
      expect(ms, lessThan(100), reason: '$name took $ms ms');
    });
  }
}
