import 'package:intl/intl.dart';

/// Currencies offered in Settings (S34). Only the symbol changes on a switch;
/// amounts are never converted.
enum Currency {
  myr('MYR', 'RM'),
  sgd('SGD', r'S$'),
  usd('USD', r'$'),
  aud('AUD', r'A$'),
  bnd('BND', r'B$'),
  eur('EUR', '€'),
  idr('IDR', 'Rp');

  new(this.code, this.symbol);

  final String code;
  final String symbol;

  /// The currency for a stored ISO code, or MYR if it's unknown.
  static Currency fromCode(String code) => Currency.values.firstWhere(
    (c) => c.code == code,
    orElse: () => Currency.myr,
  );
}

enum MoneySign {
  /// Minus only when the value is negative.
  auto,

  /// Always "−", for expenses stored as positive amounts.
  expense,

  /// Always "+", for income.
  income,
}

/// Formats integer minor units, e.g. 124000 → "RM 1,240.00".
///
/// Every currency is shown with two decimals, since amounts are stored as
/// minor units and switching currency never converts them.
class MoneyFormatter {
  const new(this.currency);

  final Currency currency;

  static const minus = '−';
  static final _grouped = NumberFormat('#,##0', 'en_US');

  String format(int minor, {MoneySign sign = MoneySign.auto}) {
    final (:head, :cents) = split(minor, sign: sign);
    return '$head$cents';
  }

  /// The amount without its cents, and the cents with their point, so large
  /// amounts can show the cents smaller.
  ({String head, String cents}) split(
    int minor, {
    MoneySign sign = MoneySign.auto,
  }) {
    final abs = minor.abs();
    final prefix = switch (sign) {
      MoneySign.expense => minus,
      MoneySign.income => '+',
      MoneySign.auto => minor < 0 ? minus : '',
    };
    final whole = _grouped.format(abs ~/ 100);
    final cents = (abs % 100).toString().padLeft(2, '0');
    return (head: '$prefix${currency.symbol} $whole', cents: '.$cents');
  }
}
