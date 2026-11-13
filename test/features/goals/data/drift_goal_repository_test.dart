import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/goals/data/drift_goal_repository.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftGoalRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftGoalRepository(db);
  });
  tearDown(() => db.close());

  Future<Goal> addGoal({
    String name = 'Bali trip',
    int target = 500000,
    DateTime? month,
  }) => repo.add(
    name: name,
    iconKey: CategoryIconKey.travel,
    targetMinor: target,
    targetMonth: month ?? DateTime(2027, 3),
  );

  Future<GoalContribution> addMoney(Goal goal, int minor, [DateTime? date]) =>
      repo.addMoney(
        goal.id,
        amountMinor: minor,
        label: ' From salary ',
        date: date ?? DateTime(2026, 11, 3),
      );

  Future<Goal> reload(Goal goal) async =>
      (await repo.watch().first).firstWhere((g) => g.id == goal.id);

  test(
    'add trims the name and keeps the month; watch lists soonest first',
    () async {
      final car = await addGoal(name: ' Car ', month: DateTime(2027, 12, 20));
      final bali = await addGoal();
      expect(car.name, 'Car');
      expect(car.targetMonth, DateTime(2027, 12));
      expect(car.completedAt, isNull);
      expect(await repo.watch().first, [bali, car]);
    },
  );

  test('add and update reject a blank name or a target of 0', () async {
    await expectLater(addGoal(name: '  '), throwsArgumentError);
    await expectLater(addGoal(target: 0), throwsArgumentError);
    final bali = await addGoal();
    await expectLater(
      repo.update(bali.copyWith(name: '')),
      throwsArgumentError,
    );
  });

  test('contributions are listed newest first, withdrawals negative', () async {
    final bali = await addGoal();
    await addMoney(bali, 50000, DateTime(2026, 9, 3));
    await addMoney(bali, 40000);
    final out = await repo.withdraw(
      bali.id,
      amountMinor: 10000,
      label: 'Flights deposit back',
      date: DateTime(2026, 11, 4),
    );
    expect(out.amountMinor, -10000);
    final list = await repo.watchContributions(bali.id).first;
    expect([for (final c in list) c.amountMinor], [-10000, 40000, 50000]);
    expect(list[1].label, 'From salary');
    expect(list[1].date, DateTime(2026, 11, 3));
    expect(await repo.watchAllContributions().first, hasLength(3));
  });

  test('amounts must be above 0; a withdrawal no more than saved', () async {
    final bali = await addGoal();
    await addMoney(bali, 30000);
    await expectLater(addMoney(bali, 0), throwsArgumentError);
    await expectLater(
      repo.withdraw(
        bali.id,
        amountMinor: 30001,
        label: 'x',
        date: DateTime(2026, 11, 4),
      ),
      throwsArgumentError,
    );
    expect(await repo.watchContributions(bali.id).first, hasLength(1));
  });

  test('reaching the target completes it; dropping below reopens it', () async {
    final bali = await addGoal();
    await addMoney(bali, 400000);
    expect((await reload(bali)).completedAt, isNull);
    await addMoney(bali, 100000, DateTime(2026, 12, 3));
    expect((await reload(bali)).completedAt, DateTime.utc(2026, 12, 3));
    await repo.withdraw(
      bali.id,
      amountMinor: 1,
      label: 'x',
      date: DateTime(2026, 12, 4),
    );
    expect((await reload(bali)).completedAt, isNull);
  });

  test('lowering the target to what is saved completes it', () async {
    final bali = await addGoal();
    await addMoney(bali, 300000, DateTime(2026, 11, 3));
    await repo.update((await reload(bali)).copyWith(targetMinor: 300000));
    expect((await reload(bali)).completedAt, DateTime.utc(2026, 11, 3));
    await repo.update((await reload(bali)).copyWith(targetMinor: 400000));
    expect((await reload(bali)).completedAt, isNull);
  });

  test('deleting a goal deletes its contributions', () async {
    final bali = await addGoal();
    final car = await addGoal(name: 'Car');
    await addMoney(bali, 30000);
    await addMoney(car, 20000);
    await repo.delete(bali.id);
    expect(await repo.watch().first, [car]);
    final left = await repo.watchAllContributions().first;
    expect([for (final c in left) c.goalId], [car.id]);
  });

  test(
    'goals never create transactions, so left to spend is untouched',
    () async {
      final bali = await addGoal();
      await addMoney(bali, 50000);
      await repo.withdraw(
        bali.id,
        amountMinor: 20000,
        label: 'x',
        date: DateTime(2026, 11, 4),
      );
      expect(await db.select(db.transactions).get(), isEmpty);
    },
  );
}
