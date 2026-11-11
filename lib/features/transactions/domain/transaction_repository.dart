import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_repository.g.dart';

/// The transaction's type differs from its category's (PRD §8).
final class CategoryTypeMismatchException implements Exception {
  const new(this.categoryId, this.type);

  final int categoryId;
  final TransactionType type;

  @override
  String toString() =>
      'CategoryTypeMismatchException: category $categoryId is not ${type.name}';
}

/// The category is archived, so it can't take new transactions (PRD §5.9).
final class ArchivedCategoryException implements Exception {
  const new(this.categoryId);

  final int categoryId;

  @override
  String toString() => 'ArchivedCategoryException: category $categoryId';
}

/// Expenses and income (PRD §5.3, §5.5, §8).
abstract interface class TransactionRepository {
  /// Transactions, newest first. [period] limits them to its local days;
  /// null means all time ("Search all"). [search] matches the title, note
  /// or category name, ignoring case.
  Stream<List<Transaction>> watch({
    Period? period,
    TransactionType? type,
    int? categoryId,
    String? search,
  });

  /// Saves a new transaction and returns it with its id.
  /// Throws [ArgumentError] for an amount of 0 or less,
  /// [CategoryTypeMismatchException] or [ArchivedCategoryException].
  Future<Transaction> add({
    required int amountMinor,
    required TransactionType type,
    required int categoryId,
    required DateTime occurredAt,
    required String title,
    String? note,
  });

  /// Saves every field. Keeping an archived category is allowed, so old
  /// entries stay editable; moving to an archived one is not. Throws like
  /// [add].
  Future<void> update(Transaction transaction);

  /// Deletes the transaction and returns it, for [restore].
  Future<Transaction> delete(int id);

  /// Puts back a deleted transaction exactly, with its id (Undo, S16).
  Future<void> restore(Transaction transaction);
}

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.
@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) =>
    throw UnimplementedError('Override transactionRepositoryProvider');

/// Transactions, live, with [TransactionRepository.watch]'s filters.
@riverpod
Stream<List<Transaction>> transactions(
  Ref ref, {
  Period? period,
  TransactionType? type,
  int? categoryId,
  String? search,
}) => ref
    .watch(transactionRepositoryProvider)
    .watch(period: period, type: type, categoryId: categoryId, search: search);
