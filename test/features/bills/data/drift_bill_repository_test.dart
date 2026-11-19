import 'package:ctrlspend/core/db/app_database.dart';
import 'package:ctrlspend/features/bills/data/drift_bill_repository.dart';
import 'package:ctrlspend/features/bills/domain/bill.dart';
import 'package:ctrlspend/features/categories/data/drift_category_repository.dart';
import 'package:ctrlspend/features/transactions/data/drift_transaction_repository.dart';
import 'package:ctrlspend/features/transactions/domain/transaction.dart';
import 'package:ctrlspend/features/transactions/domain/transaction_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

// Seeded categories (PRD §8).
const food = 1;
const bills = 4;
const salary = 7;

const monthlyOn8th = BillRepeat(unit: RepeatUnit.month, day: 8);

void main() {
  late AppDatabase db;
  late DriftBillRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    // 31 Dec 2026: after every payment date in these tests.
    repo = DriftBillRepository(db, () => DateTime(2026, 12, 31));
  });
  tearDown(() => db.close());

  Future<Bill> add({
    String name = 'Unifi',
    int amountMinor = 12900,
    int categoryId = bills,
    BillRepeat repeat = monthlyOn8th,
    DateTime? nextDue,
    int? remindDaysBefore,
  }) => repo.add(
    name: name,
    amountMinor: amountMinor,
    categoryId: categoryId,
    repeat: repeat,
    nextDue: nextDue ?? DateTime(2026, 11, 8),
    remindDaysBefore: remindDaysBefore,
  );

  test('add saves a trimmed bill and watch lists soonest due first', () async {
    final unifi = await add(name: '  Unifi ', remindDaysBefore: 2);
    final gym = await add(
      name: 'Gym',
      repeat: const BillRepeat(unit: RepeatUnit.week),
      nextDue: DateTime(2026, 11, 5),
    );
    expect(unifi.name, 'Unifi');
    expect(unifi.nextDue, DateTime(2026, 11, 8));
    expect(unifi.paused, isFalse);
    expect(await repo.watch().first, [gym, unifi]);
    await repo.update(unifi.copyWith(paused: true));
    expect((await repo.watch().first).last.paused, isTrue);
  });

  group('add rejects', () {
    test('an amount of 0, a blank name or a negative reminder', () async {
      await expectLater(add(amountMinor: 0), throwsArgumentError);
      await expectLater(add(name: '  '), throwsArgumentError);
      await expectLater(add(remindDaysBefore: -1), throwsArgumentError);
    });

    test('a repeat that is not valid', () async {
      for (final repeat in const [
        BillRepeat(unit: RepeatUnit.week, every: 0),
        BillRepeat(unit: RepeatUnit.month),
        BillRepeat(unit: RepeatUnit.week, day: 8),
        BillRepeat(unit: RepeatUnit.year, day: 0),
        BillRepeat(unit: RepeatUnit.month, day: 32),
        BillRepeat(unit: RepeatUnit.day, every: 13),
        BillRepeat(unit: RepeatUnit.year, every: 2, day: 8),
      ]) {
        await expectLater(
          add(repeat: repeat),
          throwsArgumentError,
          reason: '$repeat',
        );
      }
      expect(await repo.watch().first, isEmpty);
    });

    test('an income or archived category', () async {
      await expectLater(
        add(categoryId: salary),
        throwsA(isA<CategoryTypeMismatchException>()),
      );
      await DriftCategoryRepository(db).archive(food);
      await expectLater(
        add(categoryId: food),
        throwsA(isA<ArchivedCategoryException>()),
      );
    });
  });

  test('update may keep an archived category but not move to one', () async {
    final unifi = await add();
    final rent = await add(name: 'Rent', categoryId: food);
    await DriftCategoryRepository(db).archive(food);

    await repo.update(rent.copyWith(amountMinor: 150000));
    await expectLater(
      repo.update(unifi.copyWith(categoryId: food)),
      throwsA(isA<ArchivedCategoryException>()),
    );
    final saved = await repo.watch().first;
    expect(saved.firstWhere((b) => b.name == 'Rent').amountMinor, 150000);
    expect(saved.firstWhere((b) => b.name == 'Unifi').categoryId, bills);
  });

  group('markPaid', () {
    test('records an expense linked to the bill', () async {
      final unifi = await add();
      final paidAt = DateTime(2026, 11, 8, 9, 30);
      final payment = await repo.markPaid(unifi.id, paidAt: paidAt);
      expect(payment.amountMinor, 12900);
      expect(payment.type, TransactionType.expense);
      expect(payment.categoryId, bills);
      expect(payment.title, 'Unifi');
      expect(payment.billId, unifi.id);
      expect(payment.occurredAt, paidAt.toUtc());
      expect(await DriftTransactionRepository(db).watch().first, [payment]);
    });

    test(
      'moves the due date on from the old one, paid early or late',
      () async {
        final unifi = await add();
        await repo.markPaid(unifi.id, paidAt: DateTime(2026, 11, 12));
        expect(
          (await repo.watch().first).single.nextDue,
          DateTime(2026, 12, 8),
        );
        await repo.markPaid(unifi.id, paidAt: DateTime(2026, 12, 2));
        expect((await repo.watch().first).single.nextDue, DateTime(2027, 1, 8));
      },
    );
  });

  group('markPaid with S57 changes', () {
    test('takes another amount and category', () async {
      final unifi = await add();
      final payment = await repo.markPaid(
        unifi.id,
        paidAt: DateTime(2026, 11, 8),
        amountMinor: 13500,
        categoryId: food,
      );
      expect((payment.amountMinor, payment.categoryId), (13500, food));
      expect(payment.billId, unifi.id);
      // The bill itself is unchanged.
      expect((await repo.watch().first).single.amountMinor, 12900);
    });

    test('refuses a future date, 0, or an income category', () async {
      final unifi = await add();
      await expectLater(
        repo.markPaid(unifi.id, paidAt: DateTime(2027, 1, 2)),
        throwsArgumentError,
      );
      await expectLater(
        repo.markPaid(unifi.id, paidAt: DateTime(2026, 11, 8), amountMinor: 0),
        throwsArgumentError,
      );
      await expectLater(
        repo.markPaid(
          unifi.id,
          paidAt: DateTime(2026, 11, 8),
          categoryId: salary,
        ),
        throwsA(isA<CategoryTypeMismatchException>()),
      );
      expect((await repo.watch().first).single.nextDue, DateTime(2026, 11, 8));
    });
  });

  test('delete keeps the payments without the link', () async {
    final unifi = await add();
    await repo.markPaid(unifi.id, paidAt: DateTime(2026, 11, 8));
    await repo.delete(unifi.id);
    expect(await repo.watch().first, isEmpty);
    final payments = await DriftTransactionRepository(db).watch().first;
    expect(payments.single.billId, isNull);
  });
}
