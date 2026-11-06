import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/categories/data/drift_category_repository.dart';
import 'package:ctrl_spend/features/transactions/data/drift_transaction_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Seeded categories (PRD §8).
const food = 1;
const transport = 2;
const salary = 7;

void main() {
  late AppDatabase db;
  late DriftTransactionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftTransactionRepository(db);
  });
  tearDown(() => db.close());

  Future<Transaction> add(
    String title, {
    int categoryId = food,
    TransactionType type = TransactionType.expense,
    DateTime? at,
    String? note,
    int amountMinor = 1000,
  }) => repo.add(
    amountMinor: amountMinor,
    type: type,
    categoryId: categoryId,
    occurredAt: at ?? DateTime(2026, 11, 6, 12),
    title: title,
    note: note,
  );

  Future<List<String>> titles({
    Period? period,
    TransactionType? type,
    int? categoryId,
    String? search,
  }) async => [
    for (final t
        in await repo
            .watch(
              period: period,
              type: type,
              categoryId: categoryId,
              search: search,
            )
            .first)
      t.title,
  ];

  group('watch by period', () {
    final period = periodFor(DateTime(2026, 11, 6), const DayOfMonth(15));

    test('includes the first and last day, to the minute', () async {
      await add('before', at: DateTime(2026, 10, 14, 23, 59, 59, 999));
      await add('first', at: DateTime(2026, 10, 15));
      await add('last', at: DateTime(2026, 11, 14, 23, 59, 59, 999, 999));
      await add('after', at: DateTime(2026, 11, 15));
      expect(await titles(period: period), ['last', 'first']);
    });

    test('compares instants, so a UTC time uses its local day', () async {
      final firstLocal = DateTime(2026, 10, 15);
      await add('first', at: firstLocal.toUtc());
      await add(
        'just before',
        at: firstLocal.toUtc().subtract(const Duration(milliseconds: 1)),
      );
      expect(await titles(period: period), ['first']);
    });

    test('no period means all time, newest first', () async {
      await add('old', at: DateTime(2025, 3, 10));
      await add('new', at: DateTime(2026, 11, 6));
      expect(await titles(), ['new', 'old']);
    });

    test('equal times keep the newest entry first', () async {
      await add('a');
      await add('b');
      expect(await titles(), ['b', 'a']);
    });
  });

  group('filters', () {
    setUp(() async {
      await add('Lunch', note: 'Nasi lemak');
      await add('Bus', categoryId: transport);
      await add('Pay', categoryId: salary, type: TransactionType.income);
    });

    test('by type', () async {
      expect(await titles(type: TransactionType.income), ['Pay']);
      expect(await titles(type: TransactionType.expense), ['Bus', 'Lunch']);
    });

    test('by category', () async {
      expect(await titles(categoryId: transport), ['Bus']);
    });

    test(
      'search matches title, note and category name, ignoring case',
      () async {
        expect(await titles(search: 'LUNCH'), ['Lunch']);
        expect(await titles(search: 'lemak'), ['Lunch']);
        expect(await titles(search: 'transp'), ['Bus']);
        expect(await titles(search: 'sal'), ['Pay']);
      },
    );

    test('blank search shows everything', () async {
      expect(await titles(search: '   '), hasLength(3));
    });

    test('filters combine', () async {
      expect(await titles(type: TransactionType.expense, search: 'u'), [
        'Bus',
        'Lunch',
      ]);
      expect(await titles(categoryId: food, search: 'bus'), isEmpty);
    });

    test('% and _ are matched literally', () async {
      await add('50% off');
      await add('5000 off');
      expect(await titles(search: '0%'), ['50% off']);
      expect(await titles(search: '_'), isEmpty);
    });
  });

  group('add', () {
    test('stores the time in UTC and returns the saved entry', () async {
      final local = DateTime(2026, 11, 6, 21, 15);
      final lunch = await add('Lunch', note: 'Nasi lemak', at: local);
      expect(lunch.id, isPositive);
      expect(lunch.occurredAt, local.toUtc());
      expect(lunch.occurredAt.isUtc, isTrue);
      expect(lunch.note, 'Nasi lemak');
    });

    test('rejects an amount of 0 or less', () {
      expect(add('Free', amountMinor: 0), throwsArgumentError);
      expect(add('Refund', amountMinor: -100), throwsArgumentError);
    });

    test('rejects a type that differs from the category', () {
      expect(
        add('Pay', categoryId: salary),
        throwsA(isA<CategoryTypeMismatchException>()),
      );
    });

    test('rejects an archived category', () async {
      await DriftCategoryRepository(db).archive(transport);
      expect(
        add('Bus', categoryId: transport),
        throwsA(isA<ArchivedCategoryException>()),
      );
    });
  });

  group('update', () {
    test('saves every field', () async {
      final lunch = await add('Lunch');
      final changed = lunch.copyWith(
        amountMinor: 2500,
        categoryId: transport,
        occurredAt: DateTime.utc(2026, 11, 5, 3),
        title: 'Taxi',
        note: 'Late',
      );
      await repo.update(changed);
      expect((await repo.watch().first).single, changed);
    });

    test('keeps an entry editable after its category is archived', () async {
      final lunch = await add('Lunch');
      await DriftCategoryRepository(db).archive(food);
      await repo.update(lunch.copyWith(amountMinor: 1200));
      expect((await repo.watch().first).single.amountMinor, 1200);
    });

    test('rejects moving to an archived category', () async {
      final lunch = await add('Lunch');
      await DriftCategoryRepository(db).archive(transport);
      expect(
        repo.update(lunch.copyWith(categoryId: transport)),
        throwsA(isA<ArchivedCategoryException>()),
      );
    });

    test('rejects a bad amount or type', () async {
      final lunch = await add('Lunch');
      expect(repo.update(lunch.copyWith(amountMinor: 0)), throwsArgumentError);
      expect(
        repo.update(lunch.copyWith(categoryId: salary)),
        throwsA(isA<CategoryTypeMismatchException>()),
      );
    });
  });

  test('delete then restore puts the entry back exactly', () async {
    await add('first', at: DateTime(2026, 11, 6, 9));
    final middle = await add(
      'middle',
      at: DateTime(2026, 11, 6, 12),
      note: 'Note',
    );
    await add('last', at: DateTime(2026, 11, 6, 18));

    final deleted = await repo.delete(middle.id);
    expect(deleted, middle);
    expect(await titles(), ['last', 'first']);

    await repo.restore(deleted);
    final all = await repo.watch().first;
    expect([for (final t in all) t.title], ['last', 'middle', 'first']);
    expect(all[1], middle);
  });

  test('watch emits a new list after each change', () async {
    final seen = <List<String>>[];
    final sub = repo.watch().listen(
      (ts) => seen.add([for (final t in ts) t.title]),
    );
    addTearDown(sub.cancel);

    await pumpEventQueue();
    expect(seen.single, isEmpty);
    final lunch = await add('Lunch');
    await pumpEventQueue();
    expect(seen.last, ['Lunch']);
    await repo.delete(lunch.id);
    await pumpEventQueue();
    expect(seen.last, isEmpty);
  });
}
