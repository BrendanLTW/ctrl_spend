import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

const header = 'date,time,type,category,title,amount,note';

ImportResult parse(List<String> lines) =>
    parseTransactionsCsv(lines.join('\r\n'));

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
            MissingColumns() || NotText() => 'file',
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

  test('the sample parses cleanly', () {
    final result = parseTransactionsCsv(sampleCsv);
    expect(result.problems, isEmpty);
    expect(result.rows, hasLength(3));
  });
}
