import 'package:ctrl_spend/features/categories/domain/default_categories.dart';
import 'package:ctrl_spend/features/dev/domain/sample_data.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 4, 9);
  final rows = sampleTransactions(today: today);

  test('5,000 rows over the 12 months before today, oldest first', () {
    expect(rows, hasLength(5000));
    expect(rows.first.occurredAt.isAfter(DateTime(2025, 11, 4)), isTrue);
    expect(rows.last.occurredAt.isBefore(today), isTrue);
    for (var i = 1; i < rows.length; i++) {
      expect(rows[i].occurredAt.isBefore(rows[i - 1].occurredAt), isFalse);
    }
  });

  test('default categories of the right type, positive amounts', () {
    final types = {for (final c in defaultCategories) c.name: c.type};
    for (final r in rows) {
      expect(types[r.category], r.type);
      expect(r.amountMinor, greaterThan(0));
      expect(r.title, isNotEmpty);
    }
    expect(
      rows.where((r) => r.type == TransactionType.income).length,
      inInclusiveRange(100, 250),
    );
  });

  test('the same seed gives the same data', () {
    expect(sampleTransactions(today: today), rows);
    expect(sampleTransactions(today: today, seed: 7), isNot(rows));
  });
}
