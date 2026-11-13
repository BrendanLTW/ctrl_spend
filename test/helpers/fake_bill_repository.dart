import 'dart:async';

import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/domain/bill_calculations.dart';
import 'package:ctrl_spend/features/bills/domain/bill_repository.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

import 'fake_transaction_repository.dart';

/// In-memory bills for widget tests, soonest due first. [markPaid] saves
/// its payment in [transactions], as the real repository does in one
/// database transaction. Skips the real one's checks.
class FakeBillRepository implements BillRepository {
  new({FakeTransactionRepository? transactions})
    : transactions = transactions ?? FakeTransactionRepository();

  final FakeTransactionRepository transactions;
  final _byId = <int, Bill>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  /// Everything stored, soonest due first.
  List<Bill> get all => _byId.values.toList()
    ..sort((a, b) {
      final byDue = a.nextDue.compareTo(b.nextDue);
      return byDue != 0 ? byDue : a.name.compareTo(b.name);
    });

  @override
  Stream<List<Bill>> watch() {
    StreamSubscription<void>? changes;
    late final StreamController<List<Bill>> out;
    out = StreamController<List<Bill>>(
      onListen: () {
        out.add(all);
        changes = _changes.stream.listen((_) => out.add(all));
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
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
  }) async {
    final bill = Bill(
      id: _nextId++,
      name: name.trim(),
      amountMinor: amountMinor,
      categoryId: categoryId,
      repeat: repeat,
      nextDue: nextDue,
      iconKey: iconKey,
      colorKey: colorKey,
      remindDaysBefore: remindDaysBefore,
    );
    _byId[bill.id] = bill;
    _changes.add(null);
    return bill;
  }

  @override
  Future<void> update(Bill bill) async {
    _byId[bill.id] = bill.copyWith(name: bill.name.trim());
    _changes.add(null);
  }

  @override
  Future<void> delete(int id) async {
    _byId.remove(id);
    _changes.add(null);
  }

  @override
  Future<Transaction> markPaid(int id, {required DateTime paidAt}) async {
    final bill = _byId[id]!;
    final added = await transactions.add(
      amountMinor: bill.amountMinor,
      type: TransactionType.expense,
      categoryId: bill.categoryId,
      occurredAt: paidAt,
      title: bill.name,
    );
    final payment = added.copyWith(billId: bill.id);
    await transactions.update(payment);
    _byId[id] = bill.copyWith(nextDue: nextDue(bill.nextDue, bill.repeat));
    _changes.add(null);
    return payment;
  }
}
