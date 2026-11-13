import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:ctrl_spend/features/goals/domain/goal_calculations.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime(2026, 11, 4);

Goal goal({int target = 800000, DateTime? month}) => Goal(
  id: 1,
  name: 'Car down payment',
  iconKey: CategoryIconKey.car,
  targetMinor: target,
  targetMonth: month ?? DateTime(2027, 12),
);

var _id = 1;
GoalContribution add(int minor, DateTime date) => GoalContribution(
  id: _id++,
  goalId: 1,
  amountMinor: minor,
  label: 'x',
  date: date,
);

void main() {
  test('saved adds and subtracts; to go and progress stay in range', () {
    final contributions = [
      add(50000, DateTime(2026, 9, 3)),
      add(30000, DateTime(2026, 10, 4)),
      add(-10000, DateTime(2026, 10, 20)),
    ];
    final saved = savedMinor(contributions);
    expect(saved, 70000);
    final bali = goal(target: 500000);
    expect(toGoMinor(bali, saved), 430000);
    expect(goalProgress(bali, saved), 0.14);
    expect(toGoMinor(bali, 600000), 0);
    expect(goalProgress(bali, 600000), 1);
  });

  group('monthsLeft', () {
    test('counts from next month to the target month', () {
      expect(monthsLeft(DateTime(2027, 12), today), 13);
      expect(monthsLeft(DateTime(2027, 3), today), 4);
      expect(monthsLeft(DateTime(2026, 12), today), 1);
    });

    test('is 1 in or after the target month', () {
      expect(monthsLeft(DateTime(2026, 11), today), 1);
      expect(monthsLeft(DateTime(2026, 6), today), 1);
    });
  });

  group('monthlyNeedMinor', () {
    test('rounds up to the whole unit (S31: RM 8,000 by Dec 2027)', () {
      expect(monthlyNeedMinor(goal(), 0, today), 61600);
    });

    test('an exact split is not rounded further', () {
      // RM 1,800 over Dec – Mar is RM 450 a month.
      expect(
        monthlyNeedMinor(
          goal(target: 500000, month: DateTime(2027, 3)),
          320000,
          today,
        ),
        45000,
      );
    });

    test('cents round up to the next unit', () {
      expect(
        monthlyNeedMinor(
          goal(target: 100001, month: DateTime(2026, 12)),
          0,
          today,
        ),
        100100,
      );
    });

    test('everything to go once the target month has come', () {
      expect(
        monthlyNeedMinor(
          goal(target: 500000, month: DateTime(2026, 11)),
          320000,
          today,
        ),
        180000,
      );
    });

    test('nothing once the target is reached', () {
      expect(monthlyNeedMinor(goal(), 900000, today), 0);
    });
  });

  test('status: completed, on track, or the target month has come', () {
    expect(goalStatus(goal(), 800000, today), GoalStatus.completed);
    expect(goalStatus(goal(), 100, today), GoalStatus.onTrack);
    expect(
      goalStatus(goal(month: DateTime(2026, 11)), 100, today),
      GoalStatus.targetReached,
    );
    expect(
      goalStatus(goal(month: DateTime(2026, 12)), 100, today),
      GoalStatus.onTrack,
    );
  });

  test('saved in a period counts its additions and withdrawals', () {
    final period = (start: DateTime(2026, 10, 15), end: DateTime(2026, 11, 14));
    final contributions = [
      add(40000, DateTime(2026, 11, 3)),
      add(-5000, DateTime(2026, 10, 15)),
      add(30000, DateTime(2026, 10, 14)),
      add(10000, DateTime(2026, 11, 15)),
    ];
    expect(savedInPeriodMinor(contributions, period), 35000);
  });
}
