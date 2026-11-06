import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/pill_button.dart';
import 'package:flutter/material.dart';

/// A centred empty state with one action (DESIGN §7). [card] puts it on a
/// `surface` card with a 64 px tile (S10, S15); otherwise it sits on the
/// ground with a large circle (S39). [graphic] replaces the icon (S40's
/// empty donut).
class EmptyState extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    this.icon,
    this.graphic,
    this.actionLabel,
    this.onAction,
    this.card = true,
    super.key,
  }) : assert((icon == null) != (graphic == null), 'icon or graphic'),
       assert((actionLabel == null) == (onAction == null), 'label + action');

  final String title;
  final String body;
  final IconData? icon;
  final Widget? graphic;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool card;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child:
              graphic ??
              Container(
                width: card ? 64 : 96,
                height: card ? 64 : 96,
                decoration: BoxDecoration(
                  color: colors.raised,
                  borderRadius: card
                      ? BorderRadius.circular(AppRadius.r20)
                      : null,
                  shape: card ? BoxShape.rectangle : BoxShape.circle,
                ),
                child: Icon(icon, size: card ? 28 : 36, color: colors.ink),
              ),
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: (card ? text.header : text.pageTitle).copyWith(
              color: colors.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          textAlign: TextAlign.center,
          style: text.body.copyWith(color: colors.muted),
        ),
        if ((actionLabel, onAction) case (final label?, final onTap?)) ...[
          const SizedBox(height: 22),
          PillButton(label: label, onPressed: onTap),
        ],
      ],
    );
    if (!card) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: content,
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
      ),
      child: content,
    );
  }
}
