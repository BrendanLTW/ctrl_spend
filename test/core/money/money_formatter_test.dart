import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rm = MoneyFormatter(Currency.myr);

  test('zero', () {
    expect(rm.format(0), 'RM 0.00');
  });

  test('cents are zero-padded', () {
    expect(rm.format(1), 'RM 0.01');
    expect(rm.format(1250), 'RM 12.50');
  });

  test('negative values use the U+2212 minus', () {
    expect(rm.format(-1820), '−RM 18.20');
  });

  test('expense and income signs ignore the stored sign', () {
    expect(rm.format(1250, sign: MoneySign.expense), '−RM 12.50');
    expect(rm.format(-1250, sign: MoneySign.expense), '−RM 12.50');
    expect(rm.format(480000, sign: MoneySign.income), '+RM 4,800.00');
  });

  test('large values are grouped', () {
    expect(rm.format(124000), 'RM 1,240.00');
    expect(rm.format(999999999), 'RM 9,999,999.99');
    expect(rm.format(-999999999), '−RM 9,999,999.99');
  });

  test('split separates the cents for display', () {
    expect(rm.split(124000), (head: 'RM 1,240', cents: '.00'));
    expect(rm.split(-5), (head: '−RM 0', cents: '.05'));
  });

  test('switching currency changes the symbol only', () {
    const amount = 124050;
    final formatted = {
      for (final c in Currency.values) c: MoneyFormatter(c).format(amount),
    };
    expect(formatted, {
      Currency.myr: 'RM 1,240.50',
      Currency.sgd: r'S$ 1,240.50',
      Currency.usd: r'$ 1,240.50',
      Currency.aud: r'A$ 1,240.50',
      Currency.bnd: r'B$ 1,240.50',
      Currency.eur: '€ 1,240.50',
      Currency.idr: 'Rp 1,240.50',
    });
  });
}
