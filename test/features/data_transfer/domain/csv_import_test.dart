import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

const header = 'date,time,type,category,title,amount,note';

/// 4 Nov 2026, after every date in these files.
final now = DateTime(2026, 11, 4, 23, 59);

ImportResult parse(List<String> lines) =>
    parseTransactionsCsv(lines.join('\r\n'), now: now);

void main() {
  test('reads an exported file', () {
    final result = parse([
      header,
      '2026-11-04,08:05,expense,Food,Nasi lemak,12.50,with egg',
      '2026-11-01,09:00,income,Salary,"Pay, November",4800.00,',
    ]);
    expect(result.problems, isEmpty);
    expect(result.rows, [
      (
        occurredAt: DateTime(2026, 11, 4, 8, 5),
        type: TransactionType.expense,
        category: 'Food',
        title: 'Nasi lemak',
        amountMinor: 1250,
        note: 'with egg',
      ),
      (
        occurredAt: DateTime(2026, 11, 1, 9),
        type: TransactionType.income,
        category: 'Salary',
        title: 'Pay, November',
        amountMinor: 480000,
        note: null,
      ),
    ]);
  });

  test('columns in any order; time, title and note optional', () {
    final result = parse([
      'Amount,Category,Type,Date',
      '5,Food,EXPENSE,04/11/2026',
    ]);
    expect(result.rows.single, (
      occurredAt: DateTime(2026, 11, 4, 12),
      type: TransactionType.expense,
      category: 'Food',
      title: 'Food',
      amountMinor: 500,
      note: null,
    ));
  });

  test('a byte-order mark and blank lines are ignored', () {
    final result = parseTransactionsCsv(
      '﻿$header\r\n\r\n2026-11-04,08:05,expense,Food,x,1,\r\n,,,,,,\r\n',
      now: now,
    );
    expect(result.problems, isEmpty);
    expect(result.rows, hasLength(1));
  });

  test('missing required columns are one row 1 problem', () {
    final result = parse(['date,title', '2026-11-04,x']);
    expect(result.rows, isEmpty);
    final missing = result.problems.single as MissingColumns;
    expect(missing.row, 1);
    expect(missing.columns, ['type', 'category', 'amount']);
  });

  test('every bad row is reported, by spreadsheet row, and nothing kept', () {
    final result = parse([
      header,
      '2026-11-04,08:05,expense,Food,ok,1.00,',
      '31/02/2026,08:05,expense,Food,x,1.00,',
      '2026-11-04,25:00,expense,Food,x,1.00,',
      '2026-11-04,08:05,spend,Food,x,1.00,',
      '2026-11-04,08:05,expense,,x,1.00,',
      '2026-11-04,08:05,expense,Food,x,,',
      '2026-11-04,08:05,expense,Food,x,abc,',
      ',08:05,expense,Food,x,1.00,',
    ]);
    expect(result.rows, isEmpty);
    expect(
      [
        for (final p in result.problems)
          switch (p) {
            NotADate(:final value) => '${p.row} date $value',
            NotATime(:final value) => '${p.row} time $value',
            NotAType(:final value) => '${p.row} type $value',
            EmptyField(:final column) => '${p.row} empty $column',
            NotAnAmount(:final value) => '${p.row} amount $value',
            TooLong(:final column) => '${p.row} long $column',
            FutureDate(:final value) => '${p.row} future $value',
            MissingColumns() || NotText() || TooManyRows() => 'file',
          },
      ],
      [
        '3 date 31/02/2026',
        '4 time 25:00',
        '5 type spend',
        '6 empty category',
        '7 empty amount',
        '8 amount abc',
        '9 empty date',
      ],
    );
  });

  group('parseCsvAmount', () {
    test('plain decimals, thousands commas', () {
      expect(parseCsvAmount('12.50'), 1250);
      expect(parseCsvAmount('12.5'), 1250);
      expect(parseCsvAmount('12'), 1200);
      expect(parseCsvAmount('1,234.50'), 123450);
      expect(parseCsvAmount('0.05'), 5);
    });

    test('zero, negatives, extra decimals and symbols are refused', () {
      for (final bad in ['0', '0.00', '-5', '1.234', 'RM 5', '12,5', '1,23']) {
        expect(parseCsvAmount(bad), isNull, reason: bad);
      }
    });
  });

  test('long fields and future dates are problems by row', () {
    final result = parse([
      header,
      '2026-11-04,,expense,Food,${'t' * 41},1,',
      '2026-11-04,,expense,Food,x,1,${'n' * 201}',
      '2026-11-04,,expense,${'c' * 21},x,1,',
      '2026-11-05,,expense,Food,x,1,',
      '2026-11-04,,expense,${'c' * 20},${'t' * 40},1,${'n' * 200}',
    ]);
    expect(result.rows, isEmpty);
    expect(
      [
        for (final p in result.problems)
          switch (p) {
            TooLong(:final column, :final max) => '${p.row} $column $max',
            FutureDate(:final value) => '${p.row} future $value',
            _ => '${p.row} other',
          },
      ],
      ['2 title 40', '3 note 200', '4 category 20', '5 future 2026-11-05'],
    );
  });

  test('a row dated today with no time is not in the future', () {
    final result = parseTransactionsCsv(
      '$header\r\n2026-11-04,,expense,Food,x,1,\r\n',
      now: DateTime(2026, 11, 4, 8),
    );
    expect(result.problems, isEmpty);
  });

  group('the 20,000-row limit', () {
    String rows(int n) => [
      header,
      for (var i = 0; i < n; i++) '2026-11-04,,expense,Food,x,1,',
    ].join('\r\n');

    test('20,000 rows are fine', () {
      final result = parseTransactionsCsv(rows(20000), now: now);
      expect(result.problems, isEmpty);
      expect(result.rows, hasLength(20000));
    });

    test('20,001 rows are one problem, and nothing is kept', () {
      final result = parseTransactionsCsv(rows(20001), now: now);
      expect(result.rows, isEmpty);
      expect(
        result.problems.single,
        isA<TooManyRows>().having((p) => p.count, 'count', 20001),
      );
    });
  });

  group('duplicateRows', () {
    final categories = [
      for (final (id, name, type) in [
        (1, 'Food', TransactionType.expense),
        (7, 'Salary', TransactionType.income),
      ])
        Category(
          id: id,
          name: name,
          type: type,
          iconKey: CategoryIconKey.food,
          colorKey: CategoryColorKey.orange,
          sortOrder: id,
        ),
    ];
    final existing = [
      Transaction(
        id: 1,
        amountMinor: 1250,
        type: TransactionType.expense,
        categoryId: 1,
        occurredAt: DateTime(2026, 11, 4, 8, 5).toUtc(),
        title: 'Nasi lemak',
      ),
    ];
    ImportRow row({
      DateTime? at,
      TransactionType type = TransactionType.expense,
      int amount = 1250,
      String category = 'food',
    }) => (
      occurredAt: at ?? DateTime(2026, 11, 4, 12),
      type: type,
      category: category,
      title: 'anything',
      amountMinor: amount,
      note: null,
    );

    test('same day, type, amount and category, any time or title', () {
      expect(
        duplicateRows(
          [
            row(),
            row(at: DateTime(2026, 11, 5)),
            row(amount: 1251),
            row(type: TransactionType.income, category: 'Salary'),
            row(category: 'Transport'),
          ],
          existing: existing,
          categories: categories,
        ),
        {0},
      );
    });

    test('nothing is a duplicate of an empty history', () {
      expect(
        duplicateRows([row()], existing: const [], categories: categories),
        isEmpty,
      );
    });
  });

  test('the sample parses cleanly', () {
    final result = parseTransactionsCsv(sampleCsv, now: now);
    expect(result.problems, isEmpty);
    expect(result.rows, hasLength(3));
  });

  group('checkTransactionsCsv', () {
    final now = DateTime(2026, 11, 4, 9);
    String rows(int n) => [
      'date,type,category,amount',
      for (var i = 0; i < n; i++) '2026-11-04,expense,Food,1.00',
    ].join('\r\n');

    test(
      'reports progress batch by batch and matches the sync check',
      () async {
        final progress = <(int, int)>[];
        final result = await checkTransactionsCsv(
          rows(1200),
          now: now,
          onProgress: (checked, total) => progress.add((checked, total)),
        );
        expect(progress, [(0, 1200), (500, 1200), (1000, 1200), (1200, 1200)]);
        expect(result!.rows, hasLength(1200));
        expect(result.rows, parseTransactionsCsv(rows(1200), now: now).rows);
      },
    );

    test('stops with null once cancelled', () async {
      var batches = 0;
      final result = await checkTransactionsCsv(
        rows(1200),
        now: now,
        onProgress: (_, _) => batches++,
        cancelled: () => batches >= 2,
      );
      expect(result, isNull);
      expect(batches, 2);
    });

    test('problems found before the rows come back at once', () async {
      final result = await checkTransactionsCsv('date,title\r\n', now: now);
      expect(result!.problems.single, isA<MissingColumns>());
    });
  });
}
