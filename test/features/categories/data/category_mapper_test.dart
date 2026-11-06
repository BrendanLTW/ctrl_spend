import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/categories/data/category_mapper.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<Category> roundTrip(Category category) async {
    await db.into(db.categories).insert(category.toCompanion());
    final row = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(category.id))).getSingle();
    return row.toEntity();
  }

  test('an expense category with a limit survives a round trip', () async {
    const lunch = Category(
      id: 50,
      name: 'Lunch',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.food,
      colorKey: CategoryColorKey.orange,
      sortOrder: 0,
      limitMinor: 40000,
    );
    expect(await roundTrip(lunch), lunch);
  });

  test('an archived income category without a limit survives', () async {
    const bonus = Category(
      id: 51,
      name: 'Bonus',
      type: TransactionType.income,
      iconKey: CategoryIconKey.gift,
      colorKey: CategoryColorKey.neutral,
      sortOrder: 1,
      archived: true,
    );
    expect(await roundTrip(bonus), bonus);
  });

  test('every icon and colour key survives', () async {
    for (final (i, icon) in CategoryIconKey.values.indexed) {
      final colour =
          CategoryColorKey.values[i % CategoryColorKey.values.length];
      final category = Category(
        id: 100 + i,
        name: 'Category $i',
        type: TransactionType.expense,
        iconKey: icon,
        colorKey: colour,
        sortOrder: i,
      );
      expect(await roundTrip(category), category);
    }
  });

  test('a new category gets its id from the database', () async {
    const draft = Category(
      id: 0,
      name: 'Coffee',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.coffee,
      colorKey: CategoryColorKey.purple,
      sortOrder: 6,
    );
    final id = await db
        .into(db.categories)
        .insert(draft.toCompanion().copyWith(id: const Value.absent()));
    expect(id, isPositive);
  });
}
