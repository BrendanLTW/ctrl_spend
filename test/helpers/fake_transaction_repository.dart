import 'dart:async';

import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';

/// In-memory transactions for widget tests. Filters by period, type and
/// category; search matches the title only. Drift's stream timers clash
/// with the fake clock.
class FakeTransactionRepository implements TransactionRepository {
  final _byId = <int, Transaction>{};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  /// Everything stored, newest first. Synchronous, so a test can check it
  /// without pumping for a stream's first value.
  List<Transaction> get all => _matching();

  List<Transaction> _matching({
    Period? period,
    TransactionType? type,
    int? categoryId,
    String? search,
  }) {
    final text = search?.trim().toLowerCase() ?? '';
    return _byId.values
        .where((t) => period == null || period.contains(t.occurredAt))
        .where((t) => type == null || t.type == type)
        .where((t) => categoryId == null || t.categoryId == categoryId)
        .where((t) => text.isEmpty || t.title.toLowerCase().contains(text))
        .toList()
      ..sort((a, b) {
        final byTime = b.occurredAt.compareTo(a.occurredAt);
        return byTime != 0 ? byTime : b.id - a.id;
      });
  }

  @override
  Stream<List<Transaction>> watch({
    Period? period,
    TransactionType? type,
    int? categoryId,
    String? search,
  }) {
    List<Transaction> current() => _matching(
      period: period,
      type: type,
      categoryId: categoryId,
      search: search,
    );
    StreamSubscription<void>? changes;
    late final StreamController<List<Transaction>> out;
    out = StreamController<List<Transaction>>(
      onListen: () {
        out.add(current());
        changes = _changes.stream.listen((_) => out.add(current()));
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  @override
  Future<Transaction> add({
    required int amountMinor,
    required TransactionType type,
    required int categoryId,
    required DateTime occurredAt,
    required String title,
    String? note,
  }) async {
    final transaction = Transaction(
      id: _nextId++,
      amountMinor: amountMinor,
      type: type,
      categoryId: categoryId,
      occurredAt: occurredAt.toUtc(),
      title: title,
      note: note,
    );
    _byId[transaction.id] = transaction;
    _changes.add(null);
    return transaction;
  }

  @override
  Future<void> update(Transaction transaction) async {
    _byId[transaction.id] = transaction;
    _changes.add(null);
  }

  @override
  Future<Transaction> delete(int id) async {
    final deleted = _byId.remove(id)!;
    _changes.add(null);
    return deleted;
  }

  @override
  Future<void> restore(Transaction transaction) async {
    _byId[transaction.id] = transaction;
    _changes.add(null);
  }
}
