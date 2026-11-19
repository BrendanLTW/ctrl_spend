import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/features/goals/domain/goal.dart';
import 'package:ctrlspend/features/goals/domain/goal_calculations.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime(2026, 11, 4);

Goal goal({int target = 800000, DateTime? month}) => Goal(
  id: 1,
  name: 'Car down payment',
  iconKey: CategoryIconKey.car,
  targetMinor: target,
  targetMonth: month ?? DateTime(2027, 12),
  createdAt: DateTime(2026, 11, 4),
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

  group('goalStatus (PRD §5.12)', () {
    // RM 8,000 by Dec 2027, made 4 Nov 2026: 13 months to save in.
    test('completed when saved reaches the target, or marked', () {
      expect(goalStatus(goal(), 800000, today), GoalStatus.completed);
      expect(
        goalStatus(goal().copyWith(completedAt: today), 100, today),
        GoalStatus.completed,
      );
    });

    test('in the month it was made, always on track', () {
      expect(goalStatus(goal(), 0, today), GoalStatus.onTrack);
    });

    test('on track at or above the even plan, behind below it', () {
      // March 2027 is 4 of 13 months in: 8,000 × 4 ÷ 13 = RM 2,461.54.
      final march = DateTime(2027, 3, 10);
      expect(goalStatus(goal(), 246154, march), GoalStatus.onTrack);
      expect(goalStatus(goal(), 246153, march), GoalStatus.behind);
    });

    test('in the target month the whole target is the plan', () {
      final december = DateTime(2027, 12, 20);
      expect(goalStatus(goal(), 799999, december), GoalStatus.behind);
    });

    test('past target once the target month is over', () {
      expect(
        goalStatus(goal(), 799999, DateTime(2028, 1, 2)),
        GoalStatus.pastTarget,
      );
    });

    test('a goal made in its target month is on track then', () {
      final soon = goal(month: DateTime(2026, 11));
      expect(goalStatus(soon, 0, today), GoalStatus.onTrack);
      expect(goalStatus(soon, 0, DateTime(2026, 12, 2)), GoalStatus.pastTarget);
    });
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
