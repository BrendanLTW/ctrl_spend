import 'package:csv/csv.dart';
import 'package:ctrlspend/core/period/period.dart';
import 'package:ctrlspend/features/categories/domain/category.dart';
import 'package:ctrlspend/features/transactions/domain/transaction.dart';

/// The CSV columns, in order, shared by export and import (PRD §6.4,
/// docs/csv-format.md).
abstract final class CsvColumns {
  static const date = 'date';
  static const time = 'time';
  static const type = 'type';
  static const amount = 'amount';
  static const category = 'category';
  static const title = 'title';
  static const note = 'note';

  static const List<String> header = [
    date,
    time,
    type,
    amount,
    category,
    title,
    note,
  ];
}

/// The transactions to export: in [range] (all time when null) and of the
/// included types, newest first.
List<Transaction> transactionsToExport(
  Iterable<Transaction> transactions, {
  required bool expenses,
  required bool income,
  Period? range,
}) =>
    [
      for (final t in transactions)
        if ((t.type == TransactionType.expense ? expenses : income) &&
            (range == null || range.contains(t.occurredAt)))
          t,
    ]..sort((a, b) {
      final byTime = b.occurredAt.compareTo(a.occurredAt);
      return byTime != 0 ? byTime : b.id - a.id;
    });

/// [transactions] as CSV text (docs/csv-format.md): a header, then one row
/// each in the given order, dates and times local, amounts as plain
/// decimals with two places. Every file has every column; without
/// [notes] the note column is empty, so exports always import back.
String transactionsToCsv(
  Iterable<Transaction> transactions, {
  required Map<int, Category> categories,
  required bool notes,
}) => csv.encode([
  CsvColumns.header,
  for (final t in transactions)
    [
      _date(t.occurredAt.toLocal()),
      _time(t.occurredAt.toLocal()),
      t.type.name,
      formatCsvAmount(t.amountMinor),
      categories[t.categoryId]?.name ?? '',
      t.title,
      if (notes) t.note ?? '' else '',
    ],
]);

/// "12.50" for 1250: no symbol, no grouping.
String formatCsvAmount(int minor) =>
    '${minor ~/ 100}.${(minor % 100).toString().padLeft(2, '0')}';

/// "ctrlspend-2026-11-04.csv" for [today].
String exportFileName(DateTime today) => 'ctrlspend-${_date(today)}.csv';

String _date(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

String _time(DateTime at) =>
    '${at.hour.toString().padLeft(2, '0')}:'
    '${at.minute.toString().padLeft(2, '0')}';
