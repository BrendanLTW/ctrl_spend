import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:flutter/material.dart';

/// One ranked category on S18: tile, share, amount and name. Read as one,
/// e.g. "Food 43%, RM 328".
class CategoryShareCard extends StatelessWidget {
  const new({
    required this.category,
    required this.percent,
    required this.amount,
    required this.semanticLabel,
    super.key,
  });

  final Category category;
  final int percent;

  /// Formatted, e.g. "RM 328".
  final String amount;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryTile.forKey(
                  category.iconKey,
                  color: category.colorKey,
                  size: CategoryTileSize.compact,
                ),
                const Spacer(),
                Text(
                  '$percent%',
                  style: text.rowTitle.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Never cut short (DESIGN §10): scales down instead.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: text.statValue.copyWith(color: colors.ink),
              ),
            ),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.body.copyWith(color: colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
