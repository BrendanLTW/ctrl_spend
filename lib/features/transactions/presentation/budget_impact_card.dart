import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S41's Budget impact: [name] against its limit in the transaction's
/// period, coloured by the shared budget status.
class BudgetImpactCard extends StatelessWidget {
  const new({
    required this.name,
    required this.spentMinor,
    required this.limitMinor,
    required this.currency,
    required this.caption,
    super.key,
  });

  /// "Food", or "Monthly budget" when the category has no limit.
  final String name;
  final int spentMinor;
  final int limitMinor;
  final Currency currency;

  /// "RM 328 of RM 400 this period".
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(currency);
    final status = budgetStatus(spentMinor: spentMinor, limitMinor: limitMinor);
    final colour = switch (status) {
      BudgetStatus.warning => colors.warning,
      BudgetStatus.negative => colors.negative,
      BudgetStatus.neutral || BudgetStatus.noBudget => colors.ink,
    };
    final left = leftToSpend(budgetMinor: limitMinor, spentMinor: spentMinor);
    final result = status == BudgetStatus.negative
        ? l10n.overBy(formatter.formatCompact(-left))
        : l10n.amountLeft(formatter.formatCompact(left));
    final percent = usedPercent(spentMinor: spentMinor, limitMinor: limitMinor);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: text.rowTitle.copyWith(color: colors.ink),
                ),
              ),
              Text(result, style: text.rowTitle.copyWith(color: colour)),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(
            value: limitMinor == 0 ? 1 : spentMinor / limitMinor,
            color: colour,
            semanticLabel: l10n.percentOfSpent(percent ?? 100, name),
          ),
          const SizedBox(height: 10),
          Text(caption, style: text.body.copyWith(color: colors.muted)),
        ],
      ),
    );
  }
}
