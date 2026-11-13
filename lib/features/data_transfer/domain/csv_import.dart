import 'package:csv/csv.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_export.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';

/// A valid row, ready to save. The category is still a name: the
/// repository matches or creates it.
typedef ImportRow = ImportedTransaction;

/// What's wrong with one row (S36). Rows count the header as row 1, as a
/// spreadsheet shows them.
sealed class ImportProblem {
  const new(this.row);

  final int row;
}

/// The file isn't UTF-8 text.
final class NotText extends ImportProblem {
  const new() : super(1);
}

final class MissingColumns extends ImportProblem {
  const new(this.columns) : super(1);

  final List<String> columns;
}

final class NotADate extends ImportProblem {
  const new(super.row, this.value);

  final String value;
}

final class NotATime extends ImportProblem {
  const new(super.row, this.value);

  final String value;
}

final class EmptyField extends ImportProblem {
  const new(super.row, this.column);

  /// One of [CsvColumns].
  final String column;
}

final class NotAnAmount extends ImportProblem {
  const new(super.row, this.value);

  final String value;
}

final class NotAType extends ImportProblem {
  const new(super.row, this.value);

  final String value;
}

/// The rows to import, or every problem found. Never both: import is all
/// or nothing (PRD §5.8).
typedef ImportResult = ({List<ImportRow> rows, List<ImportProblem> problems});

const List<String> _required = [
  CsvColumns.date,
  CsvColumns.type,
  CsvColumns.category,
  CsvColumns.amount,
];

/// Checks every row of [text] (docs/csv-format.md, Import). Columns are
/// found by their header names; `time`, `title` and `note` are optional.
/// Blank lines are skipped.
ImportResult parseTransactionsCsv(String text) {
  final body = text.startsWith('﻿') ? text.substring(1) : text;
  final table = [
    for (final row in csv.decode(body))
      [for (final cell in row) '$cell'.trim()],
  ];
  if (table.isEmpty) {
    return (rows: const [], problems: const [MissingColumns(_required)]);
  }

  final header = [for (final h in table.first) h.toLowerCase()];
  final missing = [
    for (final c in _required)
      if (!header.contains(c)) c,
  ];
  if (missing.isNotEmpty) {
    return (rows: const [], problems: [MissingColumns(missing)]);
  }
  String cell(List<String> row, String column) {
    final i = header.indexOf(column);
    return i < 0 || i >= row.length ? '' : row[i];
  }

  final rows = <ImportRow>[];
  final problems = <ImportProblem>[];
  for (final (i, row) in table.indexed.skip(1)) {
    final number = i + 1;
    if (row.every((c) => c.isEmpty)) continue;
    final before = problems.length;

    final dateText = cell(row, CsvColumns.date);
    final date = dateText.isEmpty ? null : _parseDate(dateText);
    if (dateText.isEmpty) {
      problems.add(EmptyField(number, CsvColumns.date));
    } else if (date == null) {
      problems.add(NotADate(number, dateText));
    }

    final timeText = cell(row, CsvColumns.time);
    final time = timeText.isEmpty ? (12, 0) : _parseTime(timeText);
    if (time == null) problems.add(NotATime(number, timeText));

    final typeText = cell(row, CsvColumns.type);
    final type = TransactionType.values
        .where((t) => t.name == typeText.toLowerCase())
        .firstOrNull;
    if (typeText.isEmpty) {
      problems.add(EmptyField(number, CsvColumns.type));
    } else if (type == null) {
      problems.add(NotAType(number, typeText));
    }

    final category = cell(row, CsvColumns.category);
    if (category.isEmpty) {
      problems.add(EmptyField(number, CsvColumns.category));
    }

    final amountText = cell(row, CsvColumns.amount);
    final amount = amountText.isEmpty ? null : parseCsvAmount(amountText);
    if (amountText.isEmpty) {
      problems.add(EmptyField(number, CsvColumns.amount));
    } else if (amount == null) {
      problems.add(NotAnAmount(number, amountText));
    }

    if (problems.length > before) continue;
    final title = cell(row, CsvColumns.title);
    final note = cell(row, CsvColumns.note);
    rows.add((
      occurredAt: DateTime(date!.year, date.month, date.day, time!.$1, time.$2),
      type: type!,
      category: category,
      title: title.isEmpty ? category : title,
      amountMinor: amount!,
      note: note.isEmpty ? null : note,
    ));
  }
  return problems.isEmpty
      ? (rows: rows, problems: const [])
      : (rows: const [], problems: problems);
}

/// 1250 for "12.50", "12.5" or "12"; "1,234.50" too. Null unless above 0
/// with at most two decimals.
int? parseCsvAmount(String text) {
  final match = RegExp(r'^(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d{1,2}))?$')
      .firstMatch(text);
  if (match == null) return null;
  final whole = int.parse(match[1]!.replaceAll(',', ''));
  final cents = int.parse((match[2] ?? '0').padRight(2, '0'));
  final minor = whole * 100 + cents;
  return minor > 0 ? minor : null;
}

/// `YYYY-MM-DD` or `DD/MM/YYYY`, only if the day exists.
DateTime? _parseDate(String text) {
  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(text);
  final dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(text);
  final (year, month, day) = switch ((iso, dmy)) {
    (final m?, _) => (int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!)),
    (_, final m?) => (int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!)),
    _ => (0, 0, 0),
  };
  if (year == 0) return null;
  final date = DateTime(year, month, day);
  // DateTime rolls 31 Feb over into March; a real date comes back as is.
  return date.year == year && date.month == month && date.day == day
      ? date
      : null;
}

/// `HH:mm`, 24-hour.
(int, int)? _parseTime(String text) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
  if (m == null) return null;
  final hour = int.parse(m[1]!);
  final minute = int.parse(m[2]!);
  return hour < 24 && minute < 60 ? (hour, minute) : null;
}

/// "ctrlspend-sample.csv": three rows showing the format (S36).
const sampleCsvName = 'ctrlspend-sample.csv';
const sampleCsv =
    'date,time,type,category,title,amount,note\r\n'
    '2026-11-04,08:05,expense,Food,Nasi lemak,12.50,with egg\r\n'
    '2026-11-03,18:20,expense,Transport,Grab to KLCC,18.20,\r\n'
    '2026-11-01,09:00,income,Salary,November pay,4800.00,\r\n';
