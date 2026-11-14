import 'dart:async';

import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:ctrl_spend/features/goals/domain/goal_repository.dart';

/// In-memory goals for widget tests, soonest target first. Keeps
/// `completedAt` in line with saved like the real one, and refuses to
/// withdraw more than is saved; skips its other checks.
class FakeGoalRepository implements GoalRepository {
  final _goals = <int, Goal>{};
  final _contributions = <int, GoalContribution>{};
  final _changes = StreamController<void>.broadcast();
  var _nextGoalId = 1;
  var _nextContributionId = 1;

  List<Goal> get all => _goals.values.toList()
    ..sort((a, b) {
      final byMonth = a.targetMonth.compareTo(b.targetMonth);
      return byMonth != 0 ? byMonth : a.name.compareTo(b.name);
    });

  /// Every contribution, newest first.
  List<GoalContribution> get contributions =>
      _contributions.values.toList()..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.id - a.id;
      });

  Stream<T> _watch<T>(T Function() current) {
    StreamSubscription<void>? changes;
    late final StreamController<T> out;
    out = StreamController<T>(
      onListen: () {
        out.add(current());
        changes = _changes.stream.listen((_) => out.add(current()));
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  @override
  Stream<List<Goal>> watch() => _watch(() => all);

  @override
  Stream<List<GoalContribution>> watchAllContributions() =>
      _watch(() => contributions);

  @override
  Stream<List<GoalContribution>> watchContributions(int goalId) => _watch(
    () => [
      for (final c in contributions)
        if (c.goalId == goalId) c,
    ],
  );

  @override
  Future<Goal> add({
    required String name,
    required CategoryIconKey iconKey,
    required int targetMinor,
    required DateTime targetMonth,
    required DateTime createdAt,
  }) async {
    final goal = Goal(
      id: _nextGoalId++,
      name: name.trim(),
      iconKey: iconKey,
      targetMinor: targetMinor,
      targetMonth: DateTime(targetMonth.year, targetMonth.month),
      createdAt: createdAt,
    );
    _goals[goal.id] = goal;
    _changes.add(null);
    return goal;
  }

  @override
  Future<void> update(Goal goal) async {
    _goals[goal.id] = goal.copyWith(name: goal.name.trim());
    _sync(goal.id);
    _changes.add(null);
  }

  @override
  Future<void> delete(int id) async {
    _goals.remove(id);
    _contributions.removeWhere((_, c) => c.goalId == id);
    _changes.add(null);
  }

  @override
  Future<GoalContribution> addMoney(
    int goalId, {
    required int amountMinor,
    required String label,
    required DateTime date,
  }) async => _contribute(goalId, amountMinor, label, date);

  @override
  Future<GoalContribution> withdraw(
    int goalId, {
    required int amountMinor,
    required String label,
    required DateTime date,
  }) async {
    if (amountMinor > _saved(goalId)) throw ArgumentError('too much');
    return _contribute(goalId, -amountMinor, label, date);
  }

  GoalContribution _contribute(
    int goalId,
    int signedMinor,
    String label,
    DateTime date,
  ) {
    final c = GoalContribution(
      id: _nextContributionId++,
      goalId: goalId,
      amountMinor: signedMinor,
      label: label.trim(),
      date: date,
    );
    _contributions[c.id] = c;
    _sync(goalId, on: date);
    _changes.add(null);
    return c;
  }

  int _saved(int goalId) => _contributions.values
      .where((c) => c.goalId == goalId)
      .fold(0, (sum, c) => sum + c.amountMinor);

  void _sync(int goalId, {DateTime? on}) {
    final goal = _goals[goalId]!;
    final done = _saved(goalId) >= goal.targetMinor;
    if (done == (goal.completedAt != null)) return;
    _goals[goalId] = goal.copyWith(
      completedAt: done ? (on ?? contributions.first.date) : null,
    );
  }
}
