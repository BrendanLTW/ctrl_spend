import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/pill_button.dart';
import 'package:flutter/material.dart';

/// A state circle's tint (DESIGN §7): `raised`, or the error or success
/// colours.
enum StateTone { neutral, error, success }

/// A centred state (DESIGN §7, State screens): a 96 px circle with a 40 px
/// icon (or [graphic], e.g. a spinner), a `stateTitle`, `body` `muted`
/// copy, and an optional pill action. S51, S53, S55, S59, S63, S67.
class StateView extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    this.icon,
    this.graphic,
    this.tone = StateTone.neutral,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final AppIcon? icon;

  /// Replaces the circle, e.g. S51's spinner.
  final Widget? graphic;
  final StateTone tone;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final (background, foreground) = switch (tone) {
      StateTone.neutral => (colors.raised, colors.ink),
      StateTone.error => (colors.errorBox, colors.negative),
      StateTone.success => (colors.successBox, colors.positive),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child:
                graphic ??
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  child: AppIconView(
                    icon ?? AppIcon.info,
                    size: 40,
                    stroke: 1.7,
                    color: foreground,
                  ),
                ),
          ),
          const SizedBox(height: 22),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: text.stateTitle.copyWith(color: colors.ink),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.muted),
          ),
          if ((actionLabel, onAction) case (final label?, final action?)) ...[
            const SizedBox(height: 22),
            PillButton(label: label, onPressed: action),
          ],
        ],
      ),
    );
  }
}
