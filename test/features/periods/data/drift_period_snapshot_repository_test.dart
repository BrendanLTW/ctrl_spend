import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/periods/data/drift_period_snapshot_repository.dart';
import 'package:ctrl_spend/features/periods/domain/period_snapshot.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

PeriodSnapshot snapshot(
  int month, {
  int? budget = 200000,
  Map<int, int> limits = const {},
  int spent = 76000,
}) => (
  period: (
    start: DateTime(2026, month, 15),
    end: DateTime(2026, month + 1, 14),
  ),
  budgetMinor: budget,
  limits: limits,
  spentMinor: spent,
  incomeMinor: 480000,
);

/// Checks [actual] field by field: records compare a Map by identity.
void expectSnapshot(PeriodSnapshot actual, PeriodSnapshot expected) {
  expect(actual.period, expected.period);
  expect(actual.budgetMinor, expected.budgetMinor);
  expect(actual.limits, expected.limits);
  expect(
    (actual.spentMinor, actual.incomeMinor),
    (expected.spentMinor, expected.incomeMinor),
  );
}

void main() {
  late AppDatabase db;
  late DriftPeriodSnapshotRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftPeriodSnapshotRepository(db);
  });
  tearDown(() => db.close());

  test('saves snapshots with their limits; watch lists newest first', () async {
    // Seeded categories: 1 Food, 3 Shopping.
    await repo.addAll([
      snapshot(9, limits: {1: 40000, 3: 20000}),
      snapshot(10, budget: null),
    ]);
    final saved = await repo.watch().first;
    expect(
      [for (final s in saved) s.period.start],
      [DateTime(2026, 10, 15), DateTime(2026, 9, 15)],
    );
    expectSnapshot(saved.last, snapshot(9, limits: {1: 40000, 3: 20000}));
    expect(saved.first.budgetMinor, isNull);
    expect(saved.first.limits, isEmpty);
  });

  test('a period already saved is never rewritten', () async {
    await repo.addAll([
      snapshot(9, limits: {1: 40000}),
    ]);
    await repo.addAll([
      snapshot(9, budget: 999, limits: {1: 1}, spent: 1),
      snapshot(10),
    ]);
    final saved = await repo.watch().first;
    expect(saved, hasLength(2));
    expectSnapshot(saved.last, snapshot(9, limits: {1: 40000}));
  });
}
