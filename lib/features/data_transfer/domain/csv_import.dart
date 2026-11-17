import 'package:csv/csv.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
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

/// A title, note or new category name over its limit (PRD §5.3, §5.9).
final class TooLong extends ImportProblem {
  const new(super.row, this.column, this.max);

  /// One of [CsvColumns].
  final String column;
  final int max;
}

/// More rows than an import takes ([maxImportRows], PRD §6.4).
final class TooManyRows extends ImportProblem {
  const new(this.count) : super(1);

  final int count;
}

/// A date after today: no future dates (PRD §5.3).
final class FutureDate extends ImportProblem {
  const new(super.row, this.value);

  final String value;
}

/// The most rows one file may have (PRD §6.4).
const maxImportRows = 20000;

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
/// Blank lines are skipped. Rows dated after [now] are refused.
ImportResult parseTransactionsCsv(String text, {required DateTime now}) {
  final checker = _Checker(text, now);
  if (checker.early case final result?) return result;
  checker.checkAll();
  return checker.result;
}

/// Row [checked] of [total] (S51's "Row 128 of 214").
typedef ImportProgress = void Function(int checked, int total);

/// [parseTransactionsCsv] in batches of [batch] rows, yielding between
/// them so S51 can draw [onProgress]. Null once [cancelled] says so.
Future<ImportResult?> checkTransactionsCsv(
  String text, {
  required DateTime now,
  ImportProgress? onProgress,
  bool Function()? cancelled,
  int batch = 500,
}) async {
  final checker = _Checker(text, now);
  if (checker.early case final result?) return result;
  onProgress?.call(0, checker.total);
  while (!checker.done) {
    await Future<void>.delayed(Duration.zero);
    if (cancelled?.call() ?? false) return null;
    checker.checkNext(batch);
    onProgress?.call(checker.checked, checker.total);
  }
  return checker.result;
}

/// Walks the rows of one file, collecting rows or problems.
class _Checker {
  new(String text, this.now) {
    final body = text.startsWith('\uFEFF') ? text.substring(1) : text;
    final table = [
      for (final row in csv.decode(body))
        [for (final cell in row) '$cell'.trim()],
    ];
    if (table.isEmpty) {
      early = (rows: const [], problems: const [MissingColumns(_required)]);
      return;
    }
    // Blank lines are skipped but keep their row numbers.
    _lines = [
      for (final (i, row) in table.indexed.skip(1))
        if (row.any((c) => c.isNotEmpty)) (i + 1, row),
    ];
    if (_lines.length > maxImportRows) {
      early = (rows: const [], problems: [TooManyRows(_lines.length)]);
      return;
    }
    _header = [for (final h in table.first) h.toLowerCase()];
    final missing = [
      for (final c in _required)
        if (!_header.contains(c)) c,
    ];
    if (missing.isNotEmpty) {
      early = (rows: const [], problems: [MissingColumns(missing)]);
    }
  }

  final DateTime now;

  /// The whole answer when the file fails before its rows are read.
  ImportResult? early;

  late final List<(int, List<String>)> _lines;
  late final List<String> _header;
  final _rows = <ImportRow>[];
  final _problems = <ImportProblem>[];
  int checked = 0;

  int get total => _lines.length;
  bool get done => checked >= total;

  ImportResult get result => _problems.isEmpty
      ? (rows: _rows, problems: const [])
      : (rows: const [], problems: _problems);

  void checkAll() => checkNext(total);

  void checkNext(int count) {
    final end = (checked + count).clamp(0, total);
    for (; checked < end; checked++) {
      final (number, row) = _lines[checked];
      _check(number, row);
    }
  }

  String _cell(List<String> row, String column) {
    final i = _header.indexOf(column);
    return i < 0 || i >= row.length ? '' : row[i];
  }

  void _check(int number, List<String> row) {
    final problems = _problems;
    final before = problems.length;

    final dateText = _cell(row, CsvColumns.date);
    final date = dateText.isEmpty ? null : _parseDate(dateText);
    if (dateText.isEmpty) {
      problems.add(EmptyField(number, CsvColumns.date));
    } else if (date == null) {
      problems.add(NotADate(number, dateText));
    }

    final timeText = _cell(row, CsvColumns.time);
    final time = timeText.isEmpty ? (12, 0) : _parseTime(timeText);
    if (time == null) problems.add(NotATime(number, timeText));

    final typeText = _cell(row, CsvColumns.type);
    final type = TransactionType.values
        .where((t) => t.name == typeText.toLowerCase())
        .firstOrNull;
    if (typeText.isEmpty) {
      problems.add(EmptyField(number, CsvColumns.type));
    } else if (type == null) {
      problems.add(NotAType(number, typeText));
    }

    final category = _cell(row, CsvColumns.category);
    if (category.isEmpty) {
      problems.add(EmptyField(number, CsvColumns.category));
    } else if (category.length > maxCategoryNameLength) {
      problems.add(TooLong(number, CsvColumns.category, maxCategoryNameLength));
    }

    final amountText = _cell(row, CsvColumns.amount);
    final amount = amountText.isEmpty ? null : parseCsvAmount(amountText);
    if (amountText.isEmpty) {
      problems.add(EmptyField(number, CsvColumns.amount));
    } else if (amount == null) {
      problems.add(NotAnAmount(number, amountText));
    }

    final title = _cell(row, CsvColumns.title);
    if (title.length > maxTitleLength) {
      problems.add(TooLong(number, CsvColumns.title, maxTitleLength));
    }
    final note = _cell(row, CsvColumns.note);
    if (note.length > maxNoteLength) {
      problems.add(TooLong(number, CsvColumns.note, maxNoteLength));
    }
    final occurredAt = date == null || time == null
        ? null
        : DateTime(date.year, date.month, date.day, time.$1, time.$2);
    if (occurredAt != null && isFutureDay(occurredAt, now)) {
      problems.add(FutureDate(number, dateText));
    }

    if (problems.length > before) return;
    _rows.add((
      occurredAt: occurredAt!,
      type: type!,
      category: category,
      title: title.isEmpty ? category : title,
      amountMinor: amount!,
      note: note.isEmpty ? null : note,
    ));
  }
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
    'date,time,type,amount,category,title,note\r\n'
    '2026-11-04,08:05,expense,12.50,Food,Nasi lemak,with egg\r\n'
    '2026-11-03,18:20,expense,18.20,Transport,Grab to KLCC,\r\n'
    '2026-11-01,09:00,income,4800.00,Salary,November pay,\r\n';

/// Which of [rows] (by index) match an existing transaction: the same
/// local date, type, amount and category, the category matched by name
/// and type, ignoring case (PRD §6.4). Skipped by default (S52).
Set<int> duplicateRows(
  List<ImportRow> rows, {
  required Iterable<Transaction> existing,
  required Iterable<Category> categories,
}) {
  final names = {for (final c in categories) c.id: c.name.toLowerCase()};
  (int, int, int, TransactionType, int, String) key(
    DateTime at,
    TransactionType type,
    int amountMinor,
    String category,
  ) {
    final day = at.toLocal();
    return (day.year, day.month, day.day, type, amountMinor, category);
  }

  final saved = {
    for (final t in existing)
      key(t.occurredAt, t.type, t.amountMinor, names[t.categoryId] ?? ''),
  };
  return {
    for (final (i, r) in rows.indexed)
      if (saved.contains(
        key(r.occurredAt, r.type, r.amountMinor, r.category.toLowerCase()),
      ))
        i,
  };
}
