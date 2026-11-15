import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// A status pill's colours, from the message boxes (DESIGN §3.3).
enum StatusTone { red, amber, green }

/// A small status label (DESIGN §7): 24 high, pill, 12/600, e.g. a
/// bill's "Overdue" or "Paused".
class StatusPill extends StatelessWidget {
  const new(this.label, {required this.tone, super.key});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (tone) {
      StatusTone.red => (colors.errorBox, colors.onErrorBox),
      StatusTone.amber => (colors.warningBox, colors.onWarningBox),
      StatusTone.green => (colors.successBox, colors.onSuccessBox),
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Text(
            label,
            style: context.text.pillLabel.copyWith(color: foreground),
          ),
        ),
      ),
    );
  }
}
