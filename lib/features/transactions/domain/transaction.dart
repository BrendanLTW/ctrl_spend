import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

/// Whether money goes out or comes in. Categories have a type too, and a
/// transaction's type matches its category's (PRD §8).
enum TransactionType { expense, income }

/// An expense or income entry (PRD §8).
@freezed
abstract class Transaction with _$Transaction {
  const factory({
    required int id,
    required int amountMinor,
    required TransactionType type,
    required int categoryId,

    /// In UTC; shown in local time.
    required DateTime occurredAt,
    required String title,
    String? note,
  }) = _Transaction;
}
