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
    this.sign = MoneySign.auto,
    super.key,
  });

  final int minor;
  final Currency currency;
  final MoneySign sign;
  final TextStyle style;

  /// Defaults to [style] at the hero's 18/32 size in `muted`.
  final TextStyle? centsStyle;

  static const double _centsScale = 18 / 32;

  @override
  Widget build(BuildContext context) {
    final formatter = MoneyFormatter(currency);
    final (:head, :cents) = formatter.split(minor, sign: sign);
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
          text: head,
          style: style,
          children: [TextSpan(text: cents, style: small)],
        ),
      ),
    );
  }
}
