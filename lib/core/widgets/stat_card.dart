import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';

/// A small summary card (DESIGN §7): label, value and an optional caption
/// or tinted icon. Home uses the icon (Spent, Income); Insights the
/// caption ("6 of 7" · "days this week").
class StatCard extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.semanticLabel,
    this.caption,
    this.icon,
    this.iconColor,
    super.key,
  }) : assert((icon == null) == (iconColor == null), 'icon needs a colour');

  /// Shown uppercase.
  final String label;

  /// Usually a `statValue` text, or an AmountText with a smaller symbol.
  final Widget value;

  /// The whole card read as one, e.g. "Spent, RM 760".
  final String semanticLabel;
  final String? caption;
  final AppIcon? icon;

  /// The circle's tint, from the category palette (spent: red, income:
  /// green).
  final CategoryColorKey? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            if ((icon, iconColor) case (final icon?, final tint?)) ...[
              _IconCircle(icon: icon, tint: tint),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: text.labelSm.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: text.statValue.copyWith(color: colors.ink),
                    child: value,
                  ),
                  if (caption case final caption?)
                    Text(
                      caption,
                      style: text.caption.copyWith(color: colors.muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const new({required this.icon, required this.tint});

  final AppIcon icon;
  final CategoryColorKey tint;

  @override
  Widget build(BuildContext context) {
    final tile = context.categoryColors.of(tint);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: tile.tile, shape: BoxShape.circle),
      child: AppIconView(icon, size: 22, color: tile.icon),
    );
  }
}
