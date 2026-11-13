import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/categories/data/drift_category_repository.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_export.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/transactions/data/drift_transaction_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Repos = ({
  AppDatabase db,
  DriftCategoryRepository categories,
  DriftTransactionRepository transactions,
});

Repos open() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return (
    db: db,
    categories: DriftCategoryRepository(db),
    transactions: DriftTransactionRepository(db),
  );
}

ImportedTransaction row(
  String category, {
  TransactionType type = TransactionType.expense,
  int amountMinor = 1000,
  String title = 'x',
}) => (
  occurredAt: DateTime(2026, 11, 4, 8, 5),
  type: type,
  category: category,
  title: title,
  amountMinor: amountMinor,
  note: null,
);

Future<List<Category>> allCategories(Repos r) => r.categories.watch().first;

void main() {
  group('importAll', () {
    test('matches categories by name and type, ignoring case', () async {
      final r = open();
      await r.transactions.importAll([
        row('food'),
        row('SALARY', type: TransactionType.income),
      ]);
      final byName = {for (final c in await allCategories(r)) c.name: c.id};
      final saved = await r.transactions.watch().first;
      expect(saved.map((t) => t.categoryId).toSet(), {
        byName['Food'],
        byName['Salary'],
      });
      expect(await allCategories(r), hasLength(8), reason: 'none created');
    });

    test('archived categories take their history back', () async {
      final r = open();
      final food = (await allCategories(r)).firstWhere((c) => c.name == 'Food');
      await r.categories.archive(food.id);
      await r.transactions.importAll([row('Food')]);
      expect((await r.transactions.watch().first).single.categoryId, food.id);
    });

    test('a missing category is created last, neutral, once', () async {
      final r = open();
      await r.transactions.importAll([row('Pets'), row('pets'), row('Pets')]);
      final pets = (await allCategories(r)).where((c) => c.name == 'Pets');
      expect(pets, hasLength(1));
      expect(pets.single.iconKey, CategoryIconKey.wallet);
      expect(pets.single.colorKey, CategoryColorKey.neutral);
      expect(pets.single.type, TransactionType.expense);
      final expense = (await allCategories(r))
          .where((c) => c.type == TransactionType.expense);
      expect(expense.last.name, 'Pets');
      expect(await r.transactions.watch().first, hasLength(3));
    });

    test('one bad row keeps nothing, not even new categories', () async {
      final r = open();
      await expectLater(
        r.transactions.importAll([row('Pets'), row('Food', amountMinor: 0)]),
        throwsArgumentError,
      );
      expect(await r.transactions.watch().first, isEmpty);
      expect(
        (await allCategories(r)).map((c) => c.name),
        isNot(contains('Pets')),
      );
    });
  });

  test('export then import gives the same transactions', () async {
    final source = open();
    final cats = {for (final c in await allCategories(source)) c.name: c.id};
    await source.categories.add(
      name: 'Pets',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.heart,
      colorKey: CategoryColorKey.purple,
    );
    final petsId = (await allCategories(source))
        .firstWhere((c) => c.name == 'Pets')
        .id;
    for (final (amount, category, type, at, title, note) in [
      (
        1250,
        cats['Food']!,
        TransactionType.expense,
        DateTime(2026, 11, 4, 8, 5),
        'Nasi lemak',
        'with egg',
      ),
      (
        480000,
        cats['Salary']!,
        TransactionType.income,
        DateTime(2026, 11, 1, 9),
        'Pay, "Nov"',
        null,
      ),
      (
        9900,
        petsId,
        TransactionType.expense,
        DateTime(2026, 10, 10, 23, 59),
        'Vet',
        'line one\nline two',
      ),
    ]) {
      await source.transactions.add(
        amountMinor: amount,
        type: type,
        categoryId: category,
        occurredAt: at,
        title: title,
        note: note,
      );
    }
    final sourceCategories = {
      for (final c in await allCategories(source)) c.id: c,
    };
    final exported = transactionsToCsv(
      transactionsToExport(
        await source.transactions.watch().first,
        expenses: true,
        income: true,
      ),
      categories: sourceCategories,
      notes: true,
    );

    final target = open();
    final parsed = parseTransactionsCsv(exported);
    expect(parsed.problems, isEmpty);
    await target.transactions.importAll(parsed.rows);

    Future<List<Object?>> snapshot(Repos r) async {
      final names = {for (final c in await allCategories(r)) c.id: c.name};
      return [
        for (final t in await r.transactions.watch().first)
          (
            t.occurredAt.toLocal(),
            t.type,
            names[t.categoryId],
            t.title,
            t.amountMinor,
            t.note,
          ),
      ];
    }

    expect(await snapshot(target), await snapshot(source));
  });
}
