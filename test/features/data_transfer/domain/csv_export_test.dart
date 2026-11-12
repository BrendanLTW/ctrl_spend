import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_export.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 1;

Transaction tx(
  int amountMinor, {
  int categoryId = 1,
  TransactionType type = TransactionType.expense,
  DateTime? at,
  String title = 'Lunch',
  String? note,
}) => Transaction(
  id: _nextId++,
  amountMinor: amountMinor,
  type: type,
  categoryId: categoryId,
  occurredAt: (at ?? DateTime(2026, 11, 4, 8, 5)).toUtc(),
  title: title,
  note: note,
);

const categories = {
  1: Category(
    id: 1,
    name: 'Food',
    type: TransactionType.expense,
    iconKey: CategoryIconKey.food,
    colorKey: CategoryColorKey.orange,
    sortOrder: 1,
    archived: true,
  ),
  7: Category(
    id: 7,
    name: 'Salary',
    type: TransactionType.income,
    iconKey: CategoryIconKey.wallet,
    colorKey: CategoryColorKey.green,
    sortOrder: 7,
  ),
};

void main() {
  group('transactionsToCsv', () {
    test('a header and one row each, local date and time', () {
      final text = transactionsToCsv(
        [
          tx(1250, title: 'Nasi lemak', note: 'with egg'),
          tx(
            480000,
            categoryId: 7,
            type: TransactionType.income,
            at: DateTime(2026, 11, 1, 9),
            title: 'November pay',
          ),
        ],
        categories: categories,
        notes: true,
      );
      expect(text.split('\r\n'), [
        'date,time,type,category,title,amount,note',
        '2026-11-04,08:05,expense,Food,Nasi lemak,12.50,with egg',
        '2026-11-01,09:00,income,Salary,November pay,4800.00,',
      ]);
    });

    test('without notes there is no note column', () {
      final text = transactionsToCsv(
        [tx(1250, note: 'secret')],
        categories: categories,
        notes: false,
      );
      expect(text, contains('date,time,type,category,title,amount\r\n'));
      expect(text, isNot(contains('secret')));
    });

    test('commas, quotes and new lines are quoted', () {
      final text = transactionsToCsv(
        [tx(500, title: 'Kopi, "kaw"', note: 'line one\nline two')],
        categories: categories,
        notes: true,
      );
      expect(
        text.split('\r\n').last,
        '2026-11-04,08:05,expense,Food,"Kopi, ""kaw""",5.00,"line one\nline '
        'two"',
      );
    });
  });

  test('amounts are plain decimals with two places', () {
    expect(formatCsvAmount(5), '0.05');
    expect(formatCsvAmount(1250), '12.50');
    expect(formatCsvAmount(12345600), '123456.00');
  });

  test('transactionsToExport filters by range and type, newest first', () {
    final old = tx(100, at: DateTime(2026, 10, 14, 12));
    final lunch = tx(200, at: DateTime(2026, 10, 20, 12));
    final pay = tx(
      300,
      categoryId: 7,
      type: TransactionType.income,
      at: DateTime(2026, 11, 1, 9),
    );
    final all = [old, lunch, pay];
    final period = (start: DateTime(2026, 10, 15), end: DateTime(2026, 11, 14));
    expect(transactionsToExport(all, expenses: true, income: true), [
      pay,
      lunch,
      old,
    ]);
    expect(
      transactionsToExport(all, expenses: true, income: true, range: period),
      [pay, lunch],
    );
    expect(transactionsToExport(all, expenses: true, income: false), [
      lunch,
      old,
    ]);
    expect(transactionsToExport(all, expenses: false, income: true), [pay]);
  });

  test('the file is named after today', () {
    expect(
      exportFileName(DateTime(2026, 11, 4, 23)),
      'ctrlspend-2026-11-04.csv',
    );
  });
}
