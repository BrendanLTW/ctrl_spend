import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Where a [PrimaryButton] sits.
enum PrimaryButtonSize {
  /// Pinned to the screen: 58 high, radius 22.
  screen(58, 22),

  /// Inside a sheet: 56 high, radius 20 (DESIGN §7, sheet button).
  sheet(56, 20),

  /// Under the entry screens' keypad (S12, S45): 54 high, radius 22.
  entry(54, 22);

  new(this.height, this.radius);

  final double height;
  final double radius;
}

/// The full-width primary button (DESIGN §7), `ink`. A null [onPressed]
/// disables it: `buttonDisabled` fill. [destructive] fills it red, as
/// S49's Erase everything.
class PrimaryButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.size = PrimaryButtonSize.screen,
    this.destructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final PrimaryButtonSize size;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: !enabled
            ? colors.buttonDisabled
            : destructive
            ? colors.destructive
            : colors.ink,
        borderRadius: BorderRadius.circular(size.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          // Pressed: `inkPressed`, or the red darkened by the scrim.
          highlightColor: destructive ? colors.scrim : colors.inkPressed,
          splashFactory: NoSplash.splashFactory,
          // At least its height; taller when large text wraps the label.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height,
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
                    color: !enabled
                        ? colors.onButtonDisabled
                        : destructive
                        ? colors.onDestructive
                        : colors.onInk,
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
