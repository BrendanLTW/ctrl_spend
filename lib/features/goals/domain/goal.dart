import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

/// A savings goal (PRD §5.12, v1.1).
@freezed
abstract class Goal with _$Goal {
  const factory({
    required int id,
    required String name,
    required CategoryIconKey iconKey,
    required int targetMinor,

    /// The first of the target month, local midnight.
    required DateTime targetMonth,

    /// When the goal was made, the start of its on-track plan (PRD §5.12).
    required DateTime createdAt,

    /// When saved first reached the target; null while it hasn't, or
    /// after a withdrawal took it back below.
    DateTime? completedAt,
  }) = _Goal;
}

/// Money added to a goal (positive) or withdrawn (negative). Never
/// spending: it doesn't touch "Left to spend" (PRD §8).
@freezed
abstract class GoalContribution with _$GoalContribution {
  const factory({
    required int id,
    required int goalId,
    required int amountMinor,
    required String label,

    /// A local calendar date, at midnight.
    required DateTime date,
  }) = _GoalContribution;
}
