import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/insights/domain/insight_calculations.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 1;

Transaction tx(
  int amountMinor,
  DateTime at, {
  int categoryId = 1,
  TransactionType type = TransactionType.expense,
}) => Transaction(
  id: _nextId++,
  amountMinor: amountMinor,
  type: type,
  categoryId: categoryId,
  occurredAt: at.toUtc(),
  title: 'x',
);

DateTime d(int month, int day, [int hour = 12]) =>
    DateTime(2026, month, day, hour);

void main() {
  final octToNov = (start: DateTime(2026, 10, 15), end: DateTime(2026, 11, 14));

  group('categoryShares', () {
    test('ranks by amount with whole percents', () {
      final shares = categoryShares([
        tx(32800, d(11, 1)),
        tx(19000, d(11, 2), categoryId: 2),
        tx(24200, d(11, 3), categoryId: 3),
      ], octToNov);
      expect([for (final s in shares) s.categoryId], [1, 3, 2]);
      expect([for (final s in shares) s.spentMinor], [32800, 24200, 19000]);
      expect([for (final s in shares) s.percent], [43, 32, 25]);
    });

    test('percents always add up to 100', () {
      final shares = categoryShares([
        tx(1000, d(11, 1)),
        tx(1000, d(11, 1), categoryId: 2),
        tx(1000, d(11, 1), categoryId: 3),
      ], octToNov);
      expect([for (final s in shares) s.percent], [34, 33, 33]);
    });

    test('ignores income and other periods; empty without spending', () {
      expect(
        categoryShares([
          tx(250000, d(11, 1), categoryId: 7, type: TransactionType.income),
          tx(500, d(9, 1)),
        ], octToNov),
        isEmpty,
      );
    });
  });

  group('daily pace', () {
    test('is the budget ÷ days in the period, rounded for display', () {
      expect(octToNov.days, 31);
      expect(dailyPace(period: octToNov, budgetMinor: 200000), 6452);
      expect(dailyPace(period: octToNov), isNull);
    });

    test('under pace is exact, not based on the rounded pace', () {
      bool? under(int spent) =>
          isUnderPace(spentMinor: spent, period: octToNov, budgetMinor: 200000);
      expect(under(6451), isTrue, reason: '6451 × 31 = 199,981');
      expect(under(6452), isFalse, reason: '6452 × 31 = 200,012');
      expect(under(0), isTrue);
      expect(
        isUnderPace(spentMinor: 0, period: octToNov),
        isNull,
        reason: 'no budget',
      );
    });
  });

  group('lastSevenDays', () {
    // 29 Oct – 4 Nov crosses from a 31-day period into a 30-day one.
    final today = d(11, 4, 9);
    const startDay = DayOfMonth(1);

    test('covers the 7 days ending today, oldest first', () {
      final week = lastSevenDays(
        [],
        today: today,
        startDay: startDay,
        budgetMinor: 30000,
      );
      expect(week.days.first.day, DateTime(2026, 10, 29));
      expect(week.days.last.day, DateTime(2026, 11, 4));
      expect(week.days, hasLength(7));
      expect(week.totalMinor, 0);
      expect(week.biggestDay, isNull);
      expect(week.underPaceDays, 7);
    });

    test('each day uses the pace of its own period', () {
      final week = lastSevenDays(
        [
          tx(968, d(10, 31)), // Oct pace 30000/31 ≈ 967.7 → over
          tx(1000, d(11, 1)), // Nov pace 30000/30 = 1000 → under
        ],
        today: today,
        startDay: startDay,
        budgetMinor: 30000,
      );
      final byDay = {for (final s in week.days) s.day.day: s};
      expect(byDay[31]!.underPace, isFalse);
      expect(byDay[1]!.underPace, isTrue);
      expect(week.underPaceDays, 6);
    });

    test('sums days, finds the largest entry and the biggest day', () {
      final lunch = tx(1200, d(11, 2, 13));
      final dinner = tx(3500, d(11, 2, 20));
      final week = lastSevenDays(
        [
          lunch,
          dinner,
          tx(4000, d(10, 30)),
          tx(250000, d(11, 3), categoryId: 7, type: TransactionType.income),
          tx(9999, d(10, 28)),
        ],
        today: today,
        startDay: startDay,
        budgetMinor: 30000,
      );
      final nov2 = week.days.singleWhere((s) => s.day.day == 2);
      expect(nov2.spentMinor, 4700);
      expect(nov2.largest, dinner);
      expect(week.biggestDay!.day, DateTime(2026, 11, 2));
      expect(week.totalMinor, 8700);
      expect(week.averageMinor, 1243, reason: '8700 / 7 = 1242.9');
    });

    test('a tie for biggest day goes to the more recent day', () {
      final week = lastSevenDays(
        [tx(500, d(10, 30)), tx(500, d(11, 3))],
        today: today,
        startDay: startDay,
      );
      expect(week.biggestDay!.day, DateTime(2026, 11, 3));
    });

    test('without a budget there is no pace marking', () {
      final week = lastSevenDays(
        [tx(500, d(11, 3))],
        today: today,
        startDay: startDay,
      );
      expect(week.underPaceDays, isNull);
      expect(week.days.every((s) => s.underPace == null), isTrue);
    });
  });

  group('recentPeriods', () {
    final today = d(11, 6);
    const startDay = DayOfMonth(15);
    final history = [
      tx(100000, d(7, 20)),
      tx(250000, d(8, 20)),
      tx(200000, d(9, 20)),
      tx(50000, d(10, 20)),
    ];

    test('lists 6 periods oldest first, the current one so far', () {
      final trend = recentPeriods(
        history,
        today: today,
        startDay: startDay,
        budgetMinor: 200000,
      );
      expect(trend.periods.first.period.start, DateTime(2026, 5, 15));
      expect(trend.periods.last.period, octToNov);
      expect(
        [for (final p in trend.periods) p.soFar],
        [false, false, false, false, false, true],
      );
      expect(trend.periods.last.spentMinor, 50000);
    });

    test('full periods start at the first transaction', () {
      final trend = recentPeriods(
        history,
        today: today,
        startDay: startDay,
        budgetMinor: 200000,
      );
      expect([for (final p in trend.full) p.period.start.month], [7, 8, 9]);
      expect(trend.averageMinor, 183333, reason: '550,000 / 3');
      expect(trend.highest!.period.start.month, 8);
    });

    test('under budget means strictly below; exactly at it is over', () {
      final trend = recentPeriods(
        history,
        today: today,
        startDay: startDay,
        budgetMinor: 200000,
      );
      expect([for (final p in trend.full) p.overBudget], [false, true, true]);
      expect(trend.underBudgetCount, 1);
    });

    test('a tie for highest goes to the more recent period', () {
      final trend = recentPeriods(
        [tx(100, d(8, 20)), tx(100, d(9, 20))],
        today: today,
        startDay: startDay,
      );
      expect(trend.highest!.period.start.month, 9);
    });

    test('no transactions means no full periods', () {
      final trend = recentPeriods(
        [],
        today: today,
        startDay: startDay,
        budgetMinor: 200000,
      );
      expect(trend.full, isEmpty);
      expect(trend.averageMinor, isNull);
      expect(trend.underBudgetCount, isNull);
      expect(trend.highest, isNull);
    });

    test('a first period still in progress has no full periods', () {
      final trend = recentPeriods(
        [tx(500, d(10, 20))],
        today: today,
        startDay: startDay,
        budgetMinor: 200000,
      );
      expect(trend.full, isEmpty);
      expect(trend.averageMinor, isNull);
    });

    test('without a budget there are no over/under results', () {
      final trend = recentPeriods(history, today: today, startDay: startDay);
      expect(trend.periods.every((p) => p.overBudget == null), isTrue);
      expect(trend.underBudgetCount, isNull);
      expect(trend.averageMinor, 183333);
    });
  });
}
