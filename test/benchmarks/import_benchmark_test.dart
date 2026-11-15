import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/default_categories.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_export.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/dev/domain/sample_data.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

/// PRD §10: an import of 20,000 rows is checked in under 5 s. Checking is
/// parsing every row and finding duplicates against what's saved (5,000
/// sample transactions here).
void main() {
  test('20,000 rows are checked in under 5 seconds', () {
    final today = DateTime(2026, 11, 4, 9);
    final categories = [
      for (final (i, c) in defaultCategories.indexed)
        Category(
          id: i + 1,
          name: c.name,
          type: c.type,
          iconKey: c.icon,
          colorKey: c.colour,
          sortOrder: i,
        ),
    ];
    final ids = {for (final c in categories) c.name: c.id};
    Transaction toTransaction(int i, ImportRow r) => Transaction(
      id: i + 1,
      amountMinor: r.amountMinor,
      type: r.type,
      categoryId: ids[r.category]!,
      occurredAt: r.occurredAt.toUtc(),
      title: r.title,
      note: r.note,
    );
    final saved = [
      for (final (i, r) in sampleTransactions(today: today).indexed)
        toTransaction(i, r),
    ];
    final file = transactionsToCsv(
      [
        for (final (i, r) in sampleTransactions(
          today: today,
          count: 20000,
          seed: 7,
        ).indexed)
          toTransaction(i, r),
      ],
      categories: {for (final c in categories) c.id: c},
      notes: true,
    );

    final watch = Stopwatch()..start();
    final result = parseTransactionsCsv(file, now: today);
    final duplicates = duplicateRows(
      result.rows,
      existing: saved,
      categories: categories,
    );
    watch.stop();

    expect(result.problems, isEmpty);
    expect(result.rows, hasLength(20000));
    // The number is the point of the test.
    // ignore: avoid_print
    print(
      'Checked 20,000 rows in ${watch.elapsedMilliseconds} ms '
      '(${duplicates.length} duplicates)',
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
  });
}
