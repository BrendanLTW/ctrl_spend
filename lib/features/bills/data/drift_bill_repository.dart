import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/db/stored_dates.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/features/bills/data/bill_mapper.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/domain/bill_calculations.dart';
import 'package:ctrl_spend/features/bills/domain/bill_repository.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/data/category_check.dart';
import 'package:ctrl_spend/features/transactions/data/transaction_mapper.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:drift/drift.dart';

class DriftBillRepository implements BillRepository {
  /// The second argument is the app clock, for the no-future-dates rule.
  new(this._db, [this._now = DateTime.now]);

  final AppDatabase _db;
  final Clock _now;

  @override
  Stream<List<Bill>> watch() {
    final query = _db.select(_db.bills)
      ..orderBy([
        (b) => OrderingTerm(expression: b.nextDue),
        (b) => OrderingTerm(expression: b.name),
      ]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.toEntity()],
    );
  }

  @override
  Future<Bill> add({
    required String name,
    required int amountMinor,
    required int categoryId,
    required BillRepeat repeat,
    required DateTime nextDue,
    required CategoryIconKey iconKey,
    required CategoryColorKey colorKey,
    int? remindDaysBefore,
  }) => _db.transaction(() async {
    final bill = _checked(
      Bill(
        id: 0,
        name: name,
        amountMinor: amountMinor,
        categoryId: categoryId,
        repeat: repeat,
        nextDue: nextDue,
        iconKey: iconKey,
        colorKey: colorKey,
        remindDaysBefore: remindDaysBefore,
      ),
    );
    await _db.checkCategory(categoryId, TransactionType.expense);
    final row = await _db
        .into(_db.bills)
        .insertReturning(bill.toCompanion().copyWith(id: const Value.absent()));
    return row.toEntity();
  });

  @override
  Future<void> update(Bill bill) => _db.transaction(() async {
    final checked = _checked(bill);
    final current = await _byId(bill.id);
    await _db.checkCategory(
      bill.categoryId,
      TransactionType.expense,
      allowArchived: current.categoryId == bill.categoryId,
    );
    await _db.update(_db.bills).replace(checked.toCompanion());
  });

  @override
  Future<void> delete(int id) =>
      (_db.delete(_db.bills)..where((b) => b.id.equals(id))).go();

  @override
  Future<Transaction> markPaid(
    int id, {
    required DateTime paidAt,
    int? amountMinor,
    int? categoryId,
  }) => _db.transaction(() async {
    final bill = await _byId(id);
    final amount = amountMinor ?? bill.amountMinor;
    final category = categoryId ?? bill.categoryId;
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amountMinor', 'must be > 0');
    }
    await _db.checkCategory(
      category,
      TransactionType.expense,
      allowArchived: category == bill.categoryId,
    );
    checkTransactionFields(
      title: bill.name,
      note: null,
      occurredAt: paidAt,
      now: _now(),
    );
    final payment = await _db
        .into(_db.transactions)
        .insertReturning(
          TransactionsCompanion.insert(
            amountMinor: amount,
            type: TransactionType.expense.name,
            categoryId: category,
            occurredAt: paidAt.toUtc(),
            title: bill.name,
            billId: Value(bill.id),
          ),
        );
    await (_db.update(_db.bills)..where((b) => b.id.equals(id))).write(
      BillsCompanion(
        nextDue: Value(storedDate(nextDue(bill.nextDue, bill.repeat))),
      ),
    );
    return payment.toEntity();
  });

  Future<Bill> _byId(int id) async => (await (_db.select(
    _db.bills,
  )..where((b) => b.id.equals(id))).getSingle()).toEntity();

  /// [bill] with its name trimmed, or an [ArgumentError].
  Bill _checked(Bill bill) {
    final name = bill.name.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(bill.name, 'name', 'must not be blank');
    }
    if (bill.amountMinor <= 0) {
      throw ArgumentError.value(bill.amountMinor, 'amountMinor', 'must be > 0');
    }
    final BillRepeat(:unit, :day) = bill.repeat;
    final needsDay = unit == RepeatUnit.month || unit == RepeatUnit.year;
    if (!isValidRepeat(bill.repeat) ||
        needsDay != (day != null) ||
        (day != null && (day < 1 || day > 31))) {
      throw ArgumentError.value(bill.repeat, 'repeat', 'is not valid');
    }
    if ((bill.remindDaysBefore ?? 0) < 0) {
      throw ArgumentError.value(
        bill.remindDaysBefore,
        'remindDaysBefore',
        'must be >= 0',
      );
    }
    return bill.copyWith(name: name);
  }
}
