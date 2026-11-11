import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S17's Monthly budget card: what's left (or over) in the status colour,
/// the bar and "RM 760.00 of RM 2,000.00 spent". Without a budget it reads
/// "Not set" with a link. Tapping it edits the budget.
class MonthlyBudgetCard extends StatelessWidget {
  const new({
    required this.spentMinor,
    required this.currency,
    required this.onTap,
    this.budgetMinor,
    super.key,
  });

  final int spentMinor;
  final int? budgetMinor;
  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(currency);
    final budget = budgetMinor;
    final status = budgetStatus(spentMinor: spentMinor, limitMinor: budget);
    final accent = switch (status) {
      BudgetStatus.warning => colors.warning,
      BudgetStatus.negative => colors.negative,
      BudgetStatus.neutral || BudgetStatus.noBudget => null,
    };
    final over = status == BudgetStatus.negative;
    final amountMinor = budget == null ? 0 : (budget - spentMinor).abs();
    final detail = budget == null
        ? l10n.setMonthlyBudget
        : l10n.spentOfBudget(
            formatter.format(spentMinor),
            formatter.format(budget),
          );
    return Semantics(
      button: true,
      label: budget == null
          ? '${l10n.monthlyBudget}, ${l10n.notSet}, $detail'
          : l10n.budgetCardLabel(
              formatter.format(amountMinor),
              over ? l10n.overWord : l10n.leftWord,
              detail,
            ),
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.monthlyBudget.toUpperCase(),
                  style: text.label.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 4),
                if (budget == null) ...[
                  Text(
                    l10n.notSet,
                    style: text.pageTitle.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail,
                    style: text.rowTitle.copyWith(
                      color: colors.ink,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.ink,
                    ),
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: AmountText(
                            amountMinor,
                            currency: currency,
                            style: text.amount.copyWith(
                              color: accent ?? colors.ink,
                            ),
                            centsColor: accent,
                          ),
                        ),
                      ),
                      Text(
                        over ? l10n.overWord : l10n.leftWord,
                        style: text.rowTitle.copyWith(
                          color: accent ?? colors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppProgressBar(
                    value: budget == 0 ? 1 : spentMinor / budget,
                    color: accent,
                    semanticLabel: '',
                  ),
                  const SizedBox(height: 12),
                  Text(detail, style: text.body.copyWith(color: colors.muted)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
