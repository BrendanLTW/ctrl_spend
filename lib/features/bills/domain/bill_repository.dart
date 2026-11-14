import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bill_repository.g.dart';

/// Recurring bills (PRD §5.11, v1.1).
abstract interface class BillRepository {
  /// Every bill, soonest due first.
  Stream<List<Bill>> watch();

  /// Saves a new bill and returns it with its id. The name is trimmed.
  /// Throws [ArgumentError] for an amount of 0 or less, a blank name or an
  /// invalid repeat, and the transaction repository's
  /// `CategoryTypeMismatchException` (an income category) or
  /// `ArchivedCategoryException`.
  Future<Bill> add({
    required String name,
    required int amountMinor,
    required int categoryId,
    required BillRepeat repeat,
    required DateTime nextDue,
    required CategoryIconKey iconKey,
    required CategoryColorKey colorKey,
    int? remindDaysBefore,
  });

  /// Saves every field. Keeping an archived category is allowed; moving to
  /// one is not. Throws like [add].
  Future<void> update(Bill bill);

  /// Deletes the bill. Its payments stay, no longer linked to it.
  Future<void> delete(int id);

  /// Records a payment (S57): an expense titled with the bill's name and
  /// linked to it, on [paidAt], of [amountMinor] (the bill's amount by
  /// default) in [categoryId] (the bill's category by default). Then moves
  /// the bill's next due date one repeat on from the old one, so paying
  /// early or late keeps its schedule. Returns the transaction. Throws
  /// like the transaction repository's `add`.
  Future<Transaction> markPaid(
    int id, {
    required DateTime paidAt,
    int? amountMinor,
    int? categoryId,
  });
}

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.
@Riverpod(keepAlive: true)
BillRepository billRepository(Ref ref) =>
    throw UnimplementedError('Override billRepositoryProvider');

/// Every bill, live, soonest due first.
@riverpod
Stream<List<Bill>> bills(Ref ref) => ref.watch(billRepositoryProvider).watch();
