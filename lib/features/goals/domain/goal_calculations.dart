import 'dart:math';

import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';

/// Where a goal stands (S29, S30).
enum GoalStatus {
  /// Saved has reached the target.
  completed,

  /// Not there yet, with the target month still ahead.
  onTrack,

  /// Not there yet, and the target month has come or gone.
  targetReached,
}

/// What's been saved: additions minus withdrawals.
int savedMinor(Iterable<GoalContribution> contributions) =>
    contributions.fold(0, (sum, c) => sum + c.amountMinor);

/// What's still to save; never below 0.
int toGoMinor(Goal goal, int savedMinor) =>
    max(0, goal.targetMinor - savedMinor);

/// Saved as a share of the target, from 0 to 1.
double goalProgress(Goal goal, int savedMinor) =>
    (savedMinor / goal.targetMinor).clamp(0, 1).toDouble();

/// Months to save in: from next month up to and including the target
/// month, so November 2026 to December 2027 is 13 (S31). At least 1: in
/// or after the target month, the rest is due now.
int monthsLeft(DateTime targetMonth, DateTime today) => max(
  1,
  (targetMonth.year - today.year) * 12 + targetMonth.month - today.month,
);

/// The monthly amount needed (PRD §8): to go ÷ months left, rounded up to
/// the whole currency unit. RM 8,000 over 13 months is RM 616.
int monthlyNeedMinor(Goal goal, int savedMinor, DateTime today) {
  final perMonth = _ceilDiv(
    toGoMinor(goal, savedMinor),
    monthsLeft(goal.targetMonth, today),
  );
  return _ceilDiv(perMonth, 100) * 100;
}

int _ceilDiv(int a, int b) => (a + b - 1) ~/ b;

GoalStatus goalStatus(Goal goal, int savedMinor, DateTime today) {
  if (savedMinor >= goal.targetMinor) return GoalStatus.completed;
  final thisMonth = DateTime(today.year, today.month);
  return goal.targetMonth.isAfter(thisMonth)
      ? GoalStatus.onTrack
      : GoalStatus.targetReached;
}

/// Net added in [period], withdrawals included (S29 "+RM 400 this month").
int savedInPeriodMinor(
  Iterable<GoalContribution> contributions,
  Period period,
) => savedMinor(contributions.where((c) => period.contains(c.date)));
