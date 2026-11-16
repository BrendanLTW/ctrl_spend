import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// What S52 and S53 say about a set of import rows: the first and last
/// dates, how many of each type, and the categories import will create.
typedef ImportSummary = ({
  DateTime first,
  DateTime last,
  int expenses,
  int income,
  List<String> newCategories,
});

/// Summarises [rows], which must not be empty. A row's category is new
/// when no category of its type has that name, ignoring case; archived
/// ones count as existing, as import reuses them. Names keep the file's
/// first spelling, in file order.
ImportSummary summarizeImport(
  List<ImportRow> rows, {
  required Iterable<Category> categories,
}) {
  final known = {for (final c in categories) (c.type, c.name.toLowerCase())};
  final newCategories = <String>[];
  var first = rows.first.occurredAt;
  var last = first;
  var expenses = 0;
  for (final r in rows) {
    if (r.occurredAt.isBefore(first)) first = r.occurredAt;
    if (r.occurredAt.isAfter(last)) last = r.occurredAt;
    if (r.type == TransactionType.expense) expenses++;
    if (known.add((r.type, r.category.toLowerCase()))) {
      newCategories.add(r.category);
    }
  }
  return (
    first: first,
    last: last,
    expenses: expenses,
    income: rows.length - expenses,
    newCategories: newCategories,
  );
}

/// The budget periods from [first]'s to [last]'s: S53's "Periods
/// updated".
Period periodsSpanned(DateTime first, DateTime last, MonthStartDay startDay) =>
    (
      start: periodFor(first, startDay).start,
      end: periodFor(last, startDay).end,
    );
