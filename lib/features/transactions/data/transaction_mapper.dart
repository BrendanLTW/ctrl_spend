import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:drift/drift.dart';

extension TransactionRowMapper on TransactionRow {
  Transaction toEntity() => Transaction(
    id: id,
    amountMinor: amountMinor,
    type: TransactionType.values.byName(type),
    categoryId: categoryId,
    occurredAt: occurredAt,
    title: title,
    note: note,
  );
}

extension TransactionMapper on Transaction {
  /// The row to update. For a new transaction, leave out the id with
  /// `toCompanion().copyWith(id: const Value.absent())`.
  TransactionsCompanion toCompanion() => TransactionsCompanion(
    id: Value(id),
    amountMinor: Value(amountMinor),
    type: Value(type.name),
    categoryId: Value(categoryId),
    occurredAt: Value(occurredAt.toUtc()),
    title: Value(title),
    note: Value(note),
  );
}
