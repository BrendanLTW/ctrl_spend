import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:flutter/material.dart';

/// One key of the [MoneyKeypad] (DESIGN §7).
class MoneyKeypadKey extends StatelessWidget {
  const new({
    required this.size,
    required this.onTap,
    this.text,
    this.icon,
    this.semanticLabel,
    super.key,
  }) : assert((text == null) != (icon == null), 'text or icon');

  final MoneyKeypadSize size;
  final VoidCallback onTap;
  final String? text;
  final IconData? icon;

  /// Read instead of [text]; required for icon keys.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final full = size == MoneyKeypadSize.full;
    final style = (full ? context.text.keypadKey : context.text.keypadKeySm)
        .copyWith(color: colors.ink);
    return Semantics(
      button: true,
      label: semanticLabel ?? text,
      excludeSemantics: true,
      child: Material(
        color: full ? colors.surface : colors.fillSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            full ? AppRadius.r18 : AppRadius.r16,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: full ? colors.raised : colors.keySoftPressed,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            height: full ? 56 : 48,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: style.fontSize, color: colors.ink)
                  : Text(text!, style: style),
            ),
          ),
        ),
      ),
    );
  }
}
