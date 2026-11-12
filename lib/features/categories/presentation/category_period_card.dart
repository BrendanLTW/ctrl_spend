import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S23's top card: the category, its type and transaction count, then this
/// period against its limit in the shared status colours ("82%",
/// "RM 72 left" or "Over by RM 10"). Without a limit, and for income,
/// there's no % or bar.
class CategoryPeriodCard extends StatelessWidget {
  const new({
    required this.category,
    required this.typeAndCount,
    required this.spentMinor,
    required this.daysLeft,
    required this.currency,
    super.key,
  });

  final Category category;

  /// "Expense · 14 transactions".
  final String typeAndCount;
  final int spentMinor;
  final int daysLeft;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(currency);
    final limit = category.type == TransactionType.expense
        ? category.limitMinor
        : null;
    final status = budgetStatus(spentMinor: spentMinor, limitMinor: limit);
    final accent = switch (status) {
      BudgetStatus.warning => colors.warning,
      BudgetStatus.negative => colors.negative,
      BudgetStatus.neutral || BudgetStatus.noBudget => colors.ink,
    };
    final percent = usedPercent(spentMinor: spentMinor, limitMinor: limit);
    final days = l10n.daysToGo(daysLeft);
    final spent = formatter.formatCompact(spentMinor);
    final result = switch (limit) {
      null => null,
      _ when spentMinor > limit => l10n.overBy(
        formatter.formatCompact(spentMinor - limit),
      ),
      _ => l10n.amountLeft(formatter.formatCompact(limit - spentMinor)),
    };
    final of = limit == null
        ? null
        : l10n.ofAmount(formatter.formatCompact(limit));
    final footerLeft = switch (result) {
      final result? => result,
      null when category.type == TransactionType.expense =>
        l10n.noLimitWithDays(days),
      null => days,
    };

    return Semantics(
      container: true,
      label: [
        category.name,
        typeAndCount,
        if (percent != null) '$percent%',
        l10n.categoryPeriodLabel(
          [spent, ?of].join(' '),
          [footerLeft, if (result != null) days].join(', '),
        ),
      ].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CategoryTile.forKey(category.iconKey, color: category.colorKey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.header.copyWith(color: colors.ink),
                      ),
                      Text(
                        typeAndCount,
                        style: text.caption.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                ),
                if (percent != null)
                  Text(
                    '$percent%',
                    style: text.rowTitle.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              l10n.thisPeriod.toUpperCase(),
              style: text.label.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 2),
            // The amount stays on one line, scaling down if it must
            // (DESIGN §10); "of RM 400" drops below it if there's no room.
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    spent,
                    style: text.amount.copyWith(color: colors.ink),
                  ),
                ),
                if (of != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      of,
                      style: text.body.copyWith(color: colors.muted),
                    ),
                  ),
              ],
            ),
            if (limit != null) ...[
              const SizedBox(height: 16),
              AppProgressBar(
                value: limit == 0 ? 1 : spentMinor / limit,
                color: accent,
                semanticLabel: '',
              ),
            ],
            const SizedBox(height: 12),
            SpreadOrStack(
              start: Text(
                footerLeft,
                style: result == null
                    ? text.body.copyWith(color: colors.muted)
                    : text.rowTitleSm.copyWith(color: accent),
              ),
              end: Text(
                result == null ? '' : days,
                style: text.body.copyWith(color: colors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
