import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// A text-only action (DESIGN §7): 16/600, 52 high touch area, no
/// underline. [muted] is for header links such as "Skip".
class TextLink extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.muted = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = muted ? colors.muted : colors.ink;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(52, 52),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        foregroundColor: color,
        overlayColor: colors.raised,
      ),
      child: Text(label, style: context.text.rowTitle.copyWith(color: color)),
    );
  }
}
