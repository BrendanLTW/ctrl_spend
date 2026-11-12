import 'package:csv/csv.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// The CSV columns, in order (docs/csv-format.md). `note` only when notes
/// are included.
abstract final class CsvColumns {
  static const date = 'date';
  static const time = 'time';
  static const type = 'type';
  static const category = 'category';
  static const title = 'title';
  static const amount = 'amount';
  static const note = 'note';

  static List<String> header({required bool notes}) => [
    date,
    time,
    type,
    category,
    title,
    amount,
    if (notes) note,
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
/// decimals with two places.
String transactionsToCsv(
  Iterable<Transaction> transactions, {
  required Map<int, Category> categories,
  required bool notes,
}) => csv.encode([
  CsvColumns.header(notes: notes),
  for (final t in transactions)
    [
      _date(t.occurredAt.toLocal()),
      _time(t.occurredAt.toLocal()),
      t.type.name,
      categories[t.categoryId]?.name ?? '',
      t.title,
      formatCsvAmount(t.amountMinor),
      if (notes) t.note ?? '',
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
