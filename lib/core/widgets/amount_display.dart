import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:flutter/material.dart';

/// The amount above a [MoneyKeypad]: optional label, the amount with a
/// smaller "RM" and muted cents, and an optional caption ("per month").
///
/// Screen readers hear [semanticLabel] as one live region, so each key
/// press is announced. The caller supplies any card around it.
class AmountDisplay extends StatelessWidget {
  const new({
    required this.minor,
    required this.currency,
    required this.semanticLabel,
    this.label,
    this.caption,
    this.size = MoneyKeypadSize.full,
    super.key,
  });

  final int minor;
  final Currency currency;

  /// Full spoken text, e.g. "Budget RM 2,000.00 per month".
  final String semanticLabel;

  /// Uppercase label above the amount ("PER MONTH").
  final String? label;

  /// Muted line below the amount ("per month").
  final String? caption;
  final MoneyKeypadSize size;

  static const double _partScale = 0.45;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final style = (size == MoneyKeypadSize.full ? text.display : text.displaySm)
        .copyWith(color: colors.ink);
    final part = style.copyWith(
      fontSize: style.fontSize! * _partScale,
      letterSpacing: 0,
    );
    return Semantics(
      liveRegion: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label case final label?)
            Text(label, style: text.label.copyWith(color: colors.muted)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AmountText(
              minor,
              currency: currency,
              style: style,
              symbolStyle: part,
              centsStyle: part.copyWith(color: colors.muted),
            ),
          ),
          if (caption case final caption?)
            Text(caption, style: text.body.copyWith(color: colors.muted)),
        ],
      ),
    );
  }
}
