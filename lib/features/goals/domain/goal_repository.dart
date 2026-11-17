import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_repository.g.dart';

/// Savings goals and their contributions (PRD §5.12, v1.1). Nothing here
/// creates a transaction, so goals never change "Left to spend".
abstract interface class GoalRepository {
  /// Every goal, soonest target first.
  Stream<List<Goal>> watch();

  /// Saves a new goal, made at [createdAt], and returns it with its id.
  /// The name is trimmed. Throws [ArgumentError] for a blank name or a
  /// target of 0 or less.
  Future<Goal> add({
    required String name,
    required CategoryIconKey iconKey,
    required int targetMinor,
    required DateTime targetMonth,
    required DateTime createdAt,
  });

  /// Saves every field but `completedAt`. Lowering the target to what's
  /// saved completes the goal; completion is never undone. Throws like
  /// [add].
  Future<void> update(Goal goal);

  /// S62's Mark as completed: completed on [at], whatever is saved. Does
  /// nothing if it already is.
  Future<void> markCompleted(int id, {required DateTime at});

  /// Deletes the goal and its contributions.
  Future<void> delete(int id);

  /// A goal's contributions, newest first.
  Stream<List<GoalContribution>> watchContributions(int goalId);

  /// Every goal's contributions, newest first (S29's totals).
  Stream<List<GoalContribution>> watchAllContributions();

  /// Adds [amountMinor] (more than 0) to the goal. Reaching the target
  /// marks it completed on [date]; it stays completed (PRD §5.12).
  Future<GoalContribution> addMoney(
    int goalId, {
    required int amountMinor,
    required String label,
    required DateTime date,
  });

  /// Takes [amountMinor] (more than 0, at most what's saved) out of the
  /// goal. A completed goal stays completed.
  Future<GoalContribution> withdraw(
    int goalId, {
    required int amountMinor,
    required String label,
    required DateTime date,
  });
}

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.
@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) =>
    throw UnimplementedError('Override goalRepositoryProvider');

/// Every goal, live, soonest target first.
@riverpod
Stream<List<Goal>> goals(Ref ref) => ref.watch(goalRepositoryProvider).watch();

/// Every contribution, live, newest first.
@riverpod
Stream<List<GoalContribution>> goalContributions(Ref ref) =>
    ref.watch(goalRepositoryProvider).watchAllContributions();
