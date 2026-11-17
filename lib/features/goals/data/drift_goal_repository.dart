import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/db/stored_dates.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/goals/data/goal_mapper.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:ctrl_spend/features/goals/domain/goal_repository.dart';
import 'package:drift/drift.dart';

class DriftGoalRepository implements GoalRepository {
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Goal>> watch() {
    final query = _db.select(_db.goals)
      ..orderBy([
        (g) => OrderingTerm(expression: g.targetMonth),
        (g) => OrderingTerm(expression: g.name),
      ]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.toEntity()],
    );
  }

  @override
  Future<Goal> add({
    required String name,
    required CategoryIconKey iconKey,
    required int targetMinor,
    required DateTime targetMonth,
    required DateTime createdAt,
  }) async {
    final goal = _checked(
      Goal(
        id: 0,
        name: name,
        iconKey: iconKey,
        targetMinor: targetMinor,
        targetMonth: targetMonth,
        createdAt: createdAt,
      ),
    );
    final row = await _db
        .into(_db.goals)
        .insertReturning(goal.toCompanion().copyWith(id: const Value.absent()));
    return row.toEntity();
  }

  @override
  Future<void> update(Goal goal) => _db.transaction(() async {
    final checked = _checked(goal);
    final current = await _byId(goal.id);
    await _db
        .update(_db.goals)
        .replace(
          checked.copyWith(completedAt: current.completedAt).toCompanion(),
        );
    // A lower target can complete the goal.
    await _syncCompleted(goal.id);
  });

  @override
  Future<void> delete(int id) =>
      (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();

  @override
  Stream<List<GoalContribution>> watchContributions(int goalId) =>
      (_contributions()..where((c) => c.goalId.equals(goalId))).watch().map(
        (rows) => [for (final row in rows) row.toEntity()],
      );

  @override
  Stream<List<GoalContribution>> watchAllContributions() => _contributions()
      .watch()
      .map((rows) => [for (final row in rows) row.toEntity()]);

  @override
  Future<GoalContribution> addMoney(
    int goalId, {
    required int amountMinor,
    required String label,
    required DateTime date,
  }) => _contribute(goalId, amountMinor, label, date, withdraw: false);

  @override
  Future<GoalContribution> withdraw(
    int goalId, {
    required int amountMinor,
    required String label,
    required DateTime date,
  }) => _contribute(goalId, amountMinor, label, date, withdraw: true);

  SimpleSelectStatement<$GoalContributionsTable, GoalContributionRow>
  _contributions() => _db.select(_db.goalContributions)
    ..orderBy([
      (c) => OrderingTerm.desc(c.date),
      (c) => OrderingTerm.desc(c.id),
    ]);

  /// Saves a contribution, negative for a withdrawal, then brings
  /// `completedAt` into line.
  Future<GoalContribution> _contribute(
    int goalId,
    int amountMinor,
    String label,
    DateTime date, {
    required bool withdraw,
  }) => _db.transaction(() async {
    if (amountMinor <= 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', 'must be > 0');
    }
    if (withdraw && amountMinor > await _saved(goalId)) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'is more than is saved',
      );
    }
    final signedMinor = withdraw ? -amountMinor : amountMinor;
    final row = await _db
        .into(_db.goalContributions)
        .insertReturning(
          GoalContributionsCompanion.insert(
            goalId: goalId,
            amountMinor: signedMinor,
            label: label.trim(),
            date: storedDate(date),
          ),
        );
    await _syncCompleted(goalId);
    return row.toEntity();
  });

  Future<int> _saved(int goalId) async {
    final sum = _db.goalContributions.amountMinor.sum();
    final total =
        await (_db.selectOnly(_db.goalContributions)
              ..addColumns([sum])
              ..where(_db.goalContributions.goalId.equals(goalId)))
            .map((row) => row.read(sum))
            .getSingle();
    return total ?? 0;
  }

  @override
  Future<void> markCompleted(int id, {required DateTime at}) =>
      (_db.update(_db.goals)
            ..where((g) => g.id.equals(id) & g.completedAt.isNull()))
          .write(GoalsCompanion(completedAt: Value(at.toUtc())));

  /// Marks the goal completed when saved reaches the target, on the
  /// latest contribution's date. Completion is never undone (PRD §5.12):
  /// a withdrawal or a higher target leaves it completed.
  Future<void> _syncCompleted(int goalId) async {
    final goal = await _byId(goalId);
    if (goal.completedAt != null) return;
    if (await _saved(goalId) < goal.targetMinor) return;
    final latest =
        await (_contributions()
              ..where((c) => c.goalId.equals(goalId))
              ..limit(1))
            .getSingle();
    await (_db.update(_db.goals)..where((g) => g.id.equals(goalId))).write(
      GoalsCompanion(completedAt: Value(latest.date)),
    );
  }

  Future<Goal> _byId(int id) async => (await (_db.select(
    _db.goals,
  )..where((g) => g.id.equals(id))).getSingle()).toEntity();

  /// [goal] with its name trimmed, or an [ArgumentError].
  Goal _checked(Goal goal) {
    final name = goal.name.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(goal.name, 'name', 'must not be blank');
    }
    if (goal.targetMinor <= 0) {
      throw ArgumentError.value(goal.targetMinor, 'targetMinor', 'must be > 0');
    }
    return goal.copyWith(
      name: name,
      targetMonth: DateTime(goal.targetMonth.year, goal.targetMonth.month),
    );
  }
}
