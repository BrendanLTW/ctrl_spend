import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addCategory({String name = 'Coffee', String type = 'expense'}) =>
      db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: name,
              type: type,
              iconKey: 'food',
              colorKey: 'orange',
              sortOrder: 0,
            ),
          );

  Future<int> addTransaction(
    int categoryId, {
    int amountMinor = 1250,
    DateTime? occurredAt,
  }) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          amountMinor: amountMinor,
          type: 'expense',
          categoryId: categoryId,
          occurredAt: occurredAt ?? DateTime.utc(2026, 11, 6),
          title: 'Lunch',
        ),
      );

  test('schema v5 has bills, goals and period snapshots', () async {
    expect(db.schemaVersion, 5);
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .map((r) => r.read<String>('name'))
        .get();
    expect(
      tables,
      unorderedEquals([
        'categories',
        'transactions',
        'notifications',
        'preferences',
        'bills',
        'goals',
        'goal_contributions',
        'period_snapshots',
        'period_snapshot_limits',
      ]),
    );
  });

  group('categories', () {
    test('a name is unique per type, ignoring case', () async {
      await addCategory();
      expect(
        () => addCategory(name: 'coffee'),
        throwsA(isA<SqliteException>()),
      );
    });

    test('the same name may exist as expense and income', () async {
      // Gifts is seeded as income.
      await addCategory(name: 'Gifts');
      final gifts = await (db.select(
        db.categories,
      )..where((c) => c.name.equals('Gifts'))).get();
      expect(gifts.map((c) => c.type), unorderedEquals(['expense', 'income']));
    });

    test('type must be expense or income', () async {
      expect(
        () => addCategory(type: 'transfer'),
        throwsA(isA<SqliteException>()),
      );
    });

    test('a category is not archived by default', () async {
      final id = await addCategory();
      final row = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(id))).getSingle();
      expect(row.archived, isFalse);
    });
  });

  group('transactions', () {
    test('the amount must be more than 0', () async {
      final food = await addCategory();
      expect(
        () => addTransaction(food, amountMinor: 0),
        throwsA(isA<SqliteException>()),
      );
      expect(
        () => addTransaction(food, amountMinor: -100),
        throwsA(isA<SqliteException>()),
      );
    });

    test('the category must exist', () async {
      expect(() => addTransaction(999), throwsA(isA<SqliteException>()));
    });

    test('a category with transactions cannot be deleted', () async {
      final food = await addCategory();
      await addTransaction(food);
      expect(
        () => (db.delete(db.categories)..where((c) => c.id.equals(food))).go(),
        throwsA(isA<SqliteException>()),
      );
    });

    test('occurredAt comes back in UTC with milliseconds', () async {
      final at = DateTime.utc(2026, 11, 6, 23, 30, 15, 123);
      final food = await addCategory();
      await addTransaction(food, occurredAt: at);
      final row = await db.select(db.transactions).getSingle();
      expect(row.occurredAt.isUtc, isTrue);
      expect(row.occurredAt, at);
    });
  });

  group('bills', () {
    Future<int> addBill(
      int categoryId, {
      int amountMinor = 12900,
      String unit = 'month',
      int every = 1,
    }) => db
        .into(db.bills)
        .insert(
          BillsCompanion.insert(
            name: 'Unifi',
            amountMinor: amountMinor,
            categoryId: categoryId,
            repeatUnit: unit,
            repeatEvery: every,
            nextDue: DateTime.utc(2026, 11, 8),
          ),
        );

    test('the amount must be more than 0', () async {
      final id = await addCategory();
      await expectLater(
        addBill(id, amountMinor: 0),
        throwsA(isA<SqliteException>()),
      );
    });

    test('a repeat is a known unit, at least every 1', () async {
      final id = await addCategory();
      await expectLater(
        addBill(id, unit: 'fortnight'),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(addBill(id, every: 0), throwsA(isA<SqliteException>()));
      expect(await addBill(id, unit: 'day', every: 10), isPositive);
    });

    test('a category with a bill cannot be deleted', () async {
      final id = await addCategory();
      await addBill(id);
      await expectLater(
        (db.delete(db.categories)..where((c) => c.id.equals(id))).go(),
        throwsA(isA<SqliteException>()),
      );
    });

    test('deleting a bill keeps its payments without the link', () async {
      final categoryId = await addCategory();
      final billId = await addBill(categoryId);
      final paymentId = await addTransaction(categoryId);
      await (db.update(db.transactions)..where((t) => t.id.equals(paymentId)))
          .write(TransactionsCompanion(billId: Value(billId)));

      await (db.delete(db.bills)..where((b) => b.id.equals(billId))).go();

      final payment = await db.select(db.transactions).getSingle();
      expect(payment.id, paymentId);
      expect(payment.billId, isNull);
    });
  });

  group('goals', () {
    Future<int> addGoal() => db
        .into(db.goals)
        .insert(
          GoalsCompanion.insert(
            name: 'Bali trip',
            iconKey: 'travel',
            targetMinor: 500000,
            targetMonth: DateTime.utc(2027, 3),
            createdAt: DateTime.utc(2026, 8),
          ),
        );

    Future<int> contribute(int goalId, int amountMinor) => db
        .into(db.goalContributions)
        .insert(
          GoalContributionsCompanion.insert(
            goalId: goalId,
            amountMinor: amountMinor,
            label: 'From salary',
            date: DateTime.utc(2026, 11, 3),
          ),
        );

    test('a contribution adds or withdraws, never 0', () async {
      final goalId = await addGoal();
      expect(await contribute(goalId, 40000), isPositive);
      expect(await contribute(goalId, -10000), isPositive);
      await expectLater(contribute(goalId, 0), throwsA(isA<SqliteException>()));
    });

    test('deleting a goal deletes its contributions', () async {
      final goalId = await addGoal();
      await contribute(goalId, 40000);
      await (db.delete(db.goals)..where((g) => g.id.equals(goalId))).go();
      expect(await db.select(db.goalContributions).get(), isEmpty);
    });

    test('dates come back as the same UTC calendar date', () async {
      await addGoal();
      final goal = await db.select(db.goals).getSingle();
      expect(goal.targetMonth, DateTime.utc(2027, 3));
      expect(goal.targetMonth.isUtc, isTrue);
    });
  });

  group('period snapshots', () {
    Future<int> addSnapshot(DateTime start) => db
        .into(db.periodSnapshots)
        .insert(
          PeriodSnapshotsCompanion.insert(
            periodStart: start,
            periodEnd: DateTime.utc(2026, 11, 14),
            budgetMinor: const Value(200000),
            spentMinor: 76000,
            incomeMinor: 480000,
          ),
        );

    test('one per period start', () async {
      await addSnapshot(DateTime.utc(2026, 10, 15));
      await expectLater(
        addSnapshot(DateTime.utc(2026, 10, 15)),
        throwsA(isA<SqliteException>()),
      );
    });

    test('limits go with their snapshot', () async {
      final categoryId = await addCategory();
      final snapshotId = await addSnapshot(DateTime.utc(2026, 10, 15));
      await db
          .into(db.periodSnapshotLimits)
          .insert(
            PeriodSnapshotLimitsCompanion.insert(
              snapshotId: snapshotId,
              categoryId: categoryId,
              limitMinor: 40000,
            ),
          );
      await (db.delete(
        db.periodSnapshots,
      )..where((s) => s.id.equals(snapshotId))).go();
      expect(await db.select(db.periodSnapshotLimits).get(), isEmpty);
    });
  });

  test('preferences are key-value pairs with a unique key', () async {
    await db
        .into(db.preferences)
        .insert(PreferencesCompanion.insert(key: 'theme', value: 'dark'));
    await db
        .into(db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion.insert(key: 'theme', value: 'light'),
        );
    final rows = await db.select(db.preferences).get();
    expect(rows.single.value, 'light');
  });

  test('the provider can be overridden with an in-memory database', () {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    expect(container.read(appDatabaseProvider), same(db));
  });
}
