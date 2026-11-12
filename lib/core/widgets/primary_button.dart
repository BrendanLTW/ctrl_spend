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
          // At least 58 high; taller when large text wraps the label.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 58,
              minWidth: double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.text.button.copyWith(
                    color: enabled ? colors.onInk : colors.disabled,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
