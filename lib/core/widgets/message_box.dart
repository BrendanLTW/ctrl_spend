import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// The four message boxes (DESIGN §3.3).
enum MessageKind { error, warning, success, info }

/// An inline message (DESIGN §7): radius 18, padding 12 × 14, a 20 px
/// icon and `message` text. Errors are announced as they appear.
class MessageBox extends StatelessWidget {
  const new(this.text, {this.kind = MessageKind.info, this.child, super.key});

  final String text;
  final MessageKind kind;

  /// Shown instead of [text], e.g. with a bold part; [text] is still what
  /// screen readers hear.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground, icon) = switch (kind) {
      MessageKind.error => (
        colors.errorBox,
        colors.onErrorBox,
        AppIcon.circleAlert,
      ),
      MessageKind.warning => (
        colors.warningBox,
        colors.onWarningBox,
        AppIcon.warning,
      ),
      MessageKind.success => (
        colors.successBox,
        colors.onSuccessBox,
        AppIcon.checkCircle,
      ),
      MessageKind.info => (colors.infoBox, colors.onInfoBox, AppIcon.info),
    };
    final style = context.text.message.copyWith(color: foreground);
    return Semantics(
      container: true,
      liveRegion: kind == MessageKind.error,
      label: text,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.r18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: AppIconView(icon, size: 20, stroke: 2, color: foreground),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DefaultTextStyle.merge(
                style: style,
                child: child ?? Text(text, style: style),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
