import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/data_transfer/domain/import_summary.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

ImportRow row(
  DateTime at,
  String category, {
  TransactionType type = TransactionType.expense,
}) => (
  occurredAt: at,
  type: type,
  category: category,
  title: category,
  amountMinor: 100,
  note: null,
);

void main() {
  const food = Category(
    id: 1,
    name: 'Food',
    type: TransactionType.expense,
    iconKey: CategoryIconKey.food,
    colorKey: CategoryColorKey.orange,
    sortOrder: 0,
  );
  const oldGifts = Category(
    id: 2,
    name: 'Gifts',
    type: TransactionType.expense,
    iconKey: CategoryIconKey.gift,
    colorKey: CategoryColorKey.pink,
    sortOrder: 1,
    archived: true,
  );

  test('dates, counts and new categories in file order', () {
    final summary = summarizeImport(
      [
        row(DateTime(2026, 3, 2), 'Parking'),
        row(DateTime(2026), 'food'),
        row(DateTime(2026, 11, 4), 'Salary', type: TransactionType.income),
        row(DateTime(2026, 5, 5), 'Coffee'),
        row(DateTime(2026, 5, 6), 'PARKING'),
        row(DateTime(2026, 6), 'gifts'),
      ],
      categories: const [food, oldGifts],
    );
    expect(summary.first, DateTime(2026));
    expect(summary.last, DateTime(2026, 11, 4));
    expect((summary.expenses, summary.income), (5, 1));
    expect(summary.newCategories, [
      'Parking',
      'Salary',
      'Coffee',
    ], reason: 'case-insensitive; archived Gifts is reused');
  });

  test('the same name of the other type is new', () {
    final summary = summarizeImport(
      [row(DateTime(2026), 'Food', type: TransactionType.income)],
      categories: const [food],
    );
    expect(summary.newCategories, ['Food']);
  });

  test('periodsSpanned runs from the first period to the last', () {
    expect(
      periodsSpanned(
        DateTime(2026),
        DateTime(2026, 11, 4),
        const DayOfMonth(15),
      ),
      (start: DateTime(2025, 12, 15), end: DateTime(2026, 11, 14)),
    );
  });
}
