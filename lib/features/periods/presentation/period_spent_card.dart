import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S26's hero: what a period spent, a bar against the budget (coral when
/// over), "Over by RM 10" or "RM 90 under", and the budget. Without a
/// budget it says so and has no bar.
class PeriodSpentCard extends StatelessWidget {
  const new({
    required this.spentMinor,
    required this.leftMinor,
    required this.budgetMinor,
    required this.currency,
    super.key,
  });

  final int spentMinor;

  /// Budget − spent; above 0 is under. Null without a budget.
  final int? leftMinor;
  final int? budgetMinor;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final l10n = context.l10n;
    const onHero = AppColors.dark;
    final formatter = MoneyFormatter(currency);
    final budget = budgetMinor;
    final left = leftMinor;
    final over = left != null && left <= 0;
    final result = switch (left) {
      null => l10n.noBudget,
      _ when over => l10n.overBy(formatter.formatCompact(-left)),
      _ => l10n.amountUnder(formatter.formatCompact(left)),
    };
    final footerStyle = text.body.copyWith(fontWeight: FontWeight.w500);
    final budgetLabel = budget == null
        ? null
        : l10n.budgetChip(formatter.formatCompact(budget));

    return Semantics(
      container: true,
      label: [
        '${l10n.spentLabel} ${formatter.format(spentMinor)}',
        result,
        ?budgetLabel,
      ].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.colors.hero,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.spentLabel.toUpperCase(),
              style: text.label.copyWith(color: onHero.chipText),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AmountText(
                spentMinor,
                currency: currency,
                style: text.amount.copyWith(color: onHero.ink),
                centsColor: onHero.muted,
              ),
            ),
            if (budget != null) ...[
              const SizedBox(height: 22),
              AppProgressBar(
                value: spentMinor / budget,
                onHero: true,
                color: over ? onHero.negative : null,
                semanticLabel: result,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    result,
                    style: footerStyle.copyWith(
                      color: switch (left) {
                        null => onHero.muted,
                        _ when over => onHero.negative,
                        _ => onHero.positive,
                      },
                    ),
                  ),
                ),
                if (budgetLabel != null)
                  Text(
                    budgetLabel,
                    style: footerStyle.copyWith(color: onHero.ink),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
