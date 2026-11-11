import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The dashboard's budget card in one of four states (S11): left to spend
/// (under 80%, or amber at 80–99%), over budget, or no overall budget.
/// The card is dark in both themes, so it uses the dark palette.
class BudgetHero extends StatelessWidget {
  const new({
    required this.spentMinor,
    required this.period,
    required this.currency,
    required this.onTap,
    required this.onSetBudget,
    this.budgetMinor,
    super.key,
  });

  final int spentMinor;
  final int? budgetMinor;
  final Period period;
  final Currency currency;

  /// The card and its ↗ arrow.
  final VoidCallback onTap;

  /// "Set a monthly budget", shown when there's no budget.
  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final l10n = context.l10n;
    const onHero = AppColors.dark;
    final formatter = MoneyFormatter(currency);
    final status = budgetStatus(
      spentMinor: spentMinor,
      limitMinor: budgetMinor,
    );
    final budget = budgetMinor;
    final (label, amountMinor, accent) = switch (status) {
      BudgetStatus.noBudget => (l10n.spentThisPeriod, spentMinor, null),
      BudgetStatus.negative => (
        l10n.overBudgetBy,
        spentMinor - budget!,
        onHero.negative,
      ),
      BudgetStatus.warning => (
        l10n.leftToSpend,
        budget! - spentMinor,
        onHero.warning,
      ),
      BudgetStatus.neutral => (l10n.leftToSpend, budget! - spentMinor, null),
    };
    final amountStyle = text.amount.copyWith(color: accent ?? onHero.ink);
    final footerStyle = text.body.copyWith(
      color: onHero.ink,
      fontWeight: FontWeight.w500,
    );
    final percent = usedPercent(spentMinor: spentMinor, limitMinor: budget);

    final summary = [
      '$label ${formatter.format(amountMinor)}',
      if (budget != null) ...[
        l10n.amountSpent(formatter.formatCompact(spentMinor)),
        l10n.ofAmount(formatter.formatCompact(budget)),
      ] else
        formatPeriod(period, Localizations.localeOf(context).toLanguageTag()),
    ].join(', ');

    return Material(
      color: context.colors.hero,
      borderRadius: BorderRadius.circular(AppRadius.r32),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: summary,
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              highlightColor: Colors.white.withValues(alpha: 0.04),
              splashFactory: NoSplash.splashFactory,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        // White on the hero in both themes (DESIGN §7).
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 24,
                        color: AppColors.light.ink,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: text.label.copyWith(color: onHero.chipText),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: AmountText(
                              amountMinor,
                              currency: currency,
                              style: amountStyle,
                              // Amber or coral cents match the amount.
                              centsColor: accent ?? onHero.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.north_east_rounded,
                        size: 22,
                        color: onHero.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: budget == null
                // One line when both fit; the period drops below otherwise.
                ? Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      Semantics(
                        link: true,
                        child: InkWell(
                          onTap: onSetBudget,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 44),
                            child: Align(
                              widthFactor: 1,
                              child: Text(
                                l10n.setMonthlyBudget,
                                style: text.rowTitle.copyWith(
                                  color: onHero.ink,
                                  decoration: TextDecoration.underline,
                                  decorationColor: onHero.ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ExcludeSemantics(
                        child: Text(
                          formatPeriod(
                            period,
                            Localizations.localeOf(context).toLanguageTag(),
                          ),
                          style: footerStyle,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppProgressBar(
                        value: spentMinor / budget,
                        onHero: true,
                        color: accent,
                        semanticLabel: l10n.budgetSpentPercent(percent ?? 100),
                      ),
                      const SizedBox(height: 16),
                      ExcludeSemantics(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                l10n.amountSpent(
                                  formatter.formatCompact(spentMinor),
                                ),
                                style: footerStyle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                l10n.ofAmount(formatter.formatCompact(budget)),
                                textAlign: TextAlign.end,
                                style: footerStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
