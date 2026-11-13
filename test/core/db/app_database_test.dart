import 'package:ctrl_spend/core/db/app_database.dart';
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

  test('schema v2 has the four v1.0 tables and no P2 tables', () async {
    expect(db.schemaVersion, 2);
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
