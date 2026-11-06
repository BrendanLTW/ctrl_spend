import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A large amount with smaller, muted cents: "RM 1,240" + ".00" (DESIGN §4).
///
/// Row amounts show cents at full size; use [MoneyFormatter.format] for those.
class AmountText extends StatelessWidget {
  const new(
    this.minor, {
    required this.currency,
    required this.style,
    this.centsStyle,
    this.symbolStyle,
    this.sign = MoneySign.auto,
    super.key,
  });

  final int minor;
  final Currency currency;
  final MoneySign sign;
  final TextStyle style;

  /// Defaults to [style] at the hero's 18/32 size in `muted`.
  final TextStyle? centsStyle;

  /// When set, the sign and currency symbol use this style instead of
  /// [style], e.g. the smaller "RM" on the amount display.
  final TextStyle? symbolStyle;

  static const double _centsScale = 18 / 32;

  @override
  Widget build(BuildContext context) {
    final formatter = MoneyFormatter(currency);
    final (:head, :cents) = formatter.split(minor, sign: sign);
    // Sign, symbol and the space after it.
    final symbolEnd =
        head.indexOf(currency.symbol) + currency.symbol.length + 1;
    final small =
        centsStyle ??
        style.copyWith(
          fontSize: (style.fontSize ?? 14) * _centsScale,
          color: context.colors.muted,
        );
    return Semantics(
      label: formatter.format(minor, sign: sign),
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            if (symbolStyle case final symbolStyle?) ...[
              TextSpan(text: head.substring(0, symbolEnd), style: symbolStyle),
              TextSpan(text: head.substring(symbolEnd)),
            ] else
              TextSpan(text: head),
            TextSpan(text: cents, style: small),
          ],
        ),
      ),
    );
  }
}
