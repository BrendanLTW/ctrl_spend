import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// A limited category on S17: tile, name and "82%" in the status colour,
/// the bar, and "Spent RM 328 · Left RM 72" (or "Over by"). Tapping it
/// edits the limit.
class CategoryBudgetRow extends StatelessWidget {
  const new({
    required this.category,
    required this.spentMinor,
    required this.currency,
    required this.onTap,
    super.key,
  });

  /// Has a limit.
  final Category category;
  final int spentMinor;
  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(currency);
    final limit = category.limitMinor!;
    final status = budgetStatus(spentMinor: spentMinor, limitMinor: limit);
    final accent = switch (status) {
      BudgetStatus.warning => colors.warning,
      BudgetStatus.negative => colors.negative,
      BudgetStatus.neutral || BudgetStatus.noBudget => colors.ink,
    };
    final percent =
        usedPercent(spentMinor: spentMinor, limitMinor: limit) ?? 100;
    final left = limit - spentMinor;
    final detail = left < 0
        ? l10n.spentAndOver(
            formatter.formatCompact(spentMinor),
            formatter.formatCompact(-left),
          )
        : l10n.spentAndLeft(
            formatter.formatCompact(spentMinor),
            formatter.formatCompact(left),
          );
    return Semantics(
      button: true,
      label: l10n.categoryBudgetLabel(category.name, percent, detail),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CategoryTile.forKey(
                    category.iconKey,
                    color: category.colorKey,
                    size: CategoryTileSize.compact,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      category.name,
                      style: text.rowTitle.copyWith(color: colors.ink),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: text.rowTitle.copyWith(color: accent),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppProgressBar(
                value: limit == 0 ? 1 : spentMinor / limit,
                color: accent,
                semanticLabel: '',
              ),
              const SizedBox(height: 8),
              Text(detail, style: text.caption.copyWith(color: colors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
