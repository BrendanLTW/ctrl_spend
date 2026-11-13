import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum PillButtonStyle {
  /// `ink` fill: empty-state actions, dialog confirm.
  primary,

  /// Red fill, white label: destructive dialog actions.
  destructive,

  /// `fillSoft` fill: dialog Cancel.
  soft,
}

/// A pill-shaped button (DESIGN §7): 48 high, padding 0 24, 15/600.
/// [expand] stretches it to the available width, as in dialogs.
class PillButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.style = PillButtonStyle.primary,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final PillButtonStyle style;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fill, text, pressed) = switch (style) {
      PillButtonStyle.primary => (colors.ink, colors.onInk, colors.inkPressed),
      // The light theme's red in both themes: white on dark mode's lighter
      // `negative` falls below 4.5:1 contrast.
      PillButtonStyle.destructive => (
        AppColors.light.negative,
        Colors.white,
        Color.alphaBlend(Colors.black26, AppColors.light.negative),
      ),
      PillButtonStyle.soft => (colors.fillSoft, colors.ink, colors.raised),
    };
    final button = Material(
      color: fill,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        highlightColor: pressed,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.rowTitleSm.copyWith(color: text),
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
