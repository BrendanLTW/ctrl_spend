import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/categories/data/drift_category_repository.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftCategoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftCategoryRepository(db);
  });
  tearDown(() => db.close());

  Future<List<String>> names({TransactionType? type, bool? archived}) async => [
    for (final c in await repo.watch(type: type, archived: archived).first)
      c.name,
  ];

  Future<Category> byName(String name) async =>
      (await repo.watch().first).singleWhere((c) => c.name == name);

  Future<Category> addCoffee({String name = 'Coffee'}) => repo.add(
    name: name,
    type: TransactionType.expense,
    iconKey: CategoryIconKey.coffee,
    colorKey: CategoryColorKey.purple,
  );

  Future<void> addTransaction(int categoryId) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          amountMinor: 1250,
          type: 'expense',
          categoryId: categoryId,
          occurredAt: DateTime.utc(2026, 11, 6),
          title: 'Lunch',
        ),
      );

  group('first launch', () {
    test('seeds the 8 default categories in order', () async {
      expect(await names(type: TransactionType.expense), [
        'Food',
        'Transport',
        'Shopping',
        'Bills',
        'Fun',
        'Health',
      ]);
      expect(await names(type: TransactionType.income), ['Salary', 'Gifts']);
    });

    test(
      'defaults use the designed icons and colours, with no limit',
      () async {
        final salary = await byName('Salary');
        expect(salary.iconKey, CategoryIconKey.wallet);
        expect(salary.colorKey, CategoryColorKey.green);
        expect(salary.limitMinor, isNull);
        expect(salary.archived, isFalse);
        final gifts = await byName('Gifts');
        expect(gifts.colorKey, CategoryColorKey.neutral);
      },
    );
  });

  group('watch', () {
    test('filters by type and archived together', () async {
      final fun = await byName('Fun');
      final gifts = await byName('Gifts');
      await repo.archive(fun.id);
      await repo.archive(gifts.id);

      expect(await names(archived: true), ['Fun', 'Gifts']);
      expect(await names(type: TransactionType.expense, archived: false), [
        'Food',
        'Transport',
        'Shopping',
        'Bills',
        'Health',
      ]);
      expect(await names(), hasLength(8));
    });

    test('emits a new list after each change', () async {
      final seen = <List<String>>[];
      final sub = repo
          .watch(type: TransactionType.expense)
          .listen((cs) => seen.add([for (final c in cs) c.name]));
      addTearDown(sub.cancel);

      await pumpEventQueue();
      expect(seen.single, hasLength(6));
      final coffee = await addCoffee();
      await pumpEventQueue();
      expect(seen.last, contains('Coffee'));
      await repo.update(coffee.copyWith(name: 'Espresso'));
      await pumpEventQueue();
      expect(seen.last, allOf(contains('Espresso'), isNot(contains('Coffee'))));
    });
  });

  group('add', () {
    test('trims the name and puts the category last in its type', () async {
      final coffee = await addCoffee(name: '  Coffee ');
      expect(coffee.name, 'Coffee');
      expect(coffee.sortOrder, 6);
      expect((await names(type: TransactionType.expense)).last, 'Coffee');

      final bonus = await repo.add(
        name: 'Bonus',
        type: TransactionType.income,
        iconKey: CategoryIconKey.gift,
        colorKey: CategoryColorKey.green,
        limitMinor: 5000,
      );
      expect(bonus.sortOrder, 8);
      expect(bonus.limitMinor, 5000);
      expect((await names(type: TransactionType.income)).last, 'Bonus');
    });

    test('rejects a duplicate name in the same type, ignoring case', () {
      expect(
        addCoffee(name: ' food '),
        throwsA(
          isA<DuplicateCategoryNameException>().having(
            (e) => e.name,
            'name',
            'food',
          ),
        ),
      );
    });

    test('an archived category still holds its name', () async {
      await repo.archive((await byName('Gifts')).id);
      expect(
        repo.add(
          name: 'Gifts',
          type: TransactionType.income,
          iconKey: CategoryIconKey.gift,
          colorKey: CategoryColorKey.neutral,
        ),
        throwsA(isA<DuplicateCategoryNameException>()),
      );
    });

    test('allows the same name in the other type', () async {
      final gifts = await repo.add(
        name: 'Gifts',
        type: TransactionType.expense,
        iconKey: CategoryIconKey.gift,
        colorKey: CategoryColorKey.pink,
      );
      expect(gifts.type, TransactionType.expense);
    });
  });

  group('update', () {
    test('saves every field', () async {
      final food = await byName('Food');
      final changed = food.copyWith(
        name: ' Meals ',
        iconKey: CategoryIconKey.coffee,
        colorKey: CategoryColorKey.green,
        limitMinor: 40000,
      );
      await repo.update(changed);
      expect(await byName('Meals'), changed.copyWith(name: 'Meals'));
    });

    test('rejects renaming to a taken name', () async {
      final food = await byName('Food');
      expect(
        repo.update(food.copyWith(name: 'Transport')),
        throwsA(isA<DuplicateCategoryNameException>()),
      );
    });
  });

  test('archive and restore move a category between the lists', () async {
    final fun = await byName('Fun');
    await repo.archive(fun.id);
    expect(await names(archived: true), ['Fun']);
    await repo.restore(fun.id);
    expect(await names(archived: true), isEmpty);
    expect((await byName('Fun')).archived, isFalse);
  });

  group('remove', () {
    test('deletes a category with no transactions', () async {
      final health = await byName('Health');
      expect(await repo.remove(health.id), CategoryRemoval.deleted);
      expect(await names(), isNot(contains('Health')));
    });

    test('archives a category with transactions, keeping them', () async {
      final food = await byName('Food');
      await addTransaction(food.id);
      expect(await repo.remove(food.id), CategoryRemoval.archived);
      expect((await byName('Food')).archived, isTrue);
      expect(await db.select(db.transactions).get(), hasLength(1));
    });
  });
}
