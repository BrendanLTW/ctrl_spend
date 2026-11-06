import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// The full-width primary button (DESIGN §7): 58 high, radius 22, `ink`.
/// A null [onPressed] disables it.
class PrimaryButton extends StatelessWidget {
  const new({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: enabled ? colors.ink : colors.raised,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          highlightColor: colors.inkPressed,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            height: 58,
            width: double.infinity,
            child: Center(
              child: Text(
                label,
                style: context.text.button.copyWith(
                  color: enabled ? colors.onInk : colors.disabled,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
