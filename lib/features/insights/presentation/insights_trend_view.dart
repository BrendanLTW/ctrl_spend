import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/features/insights/domain/insight_calculations.dart';
import 'package:ctrl_spend/features/insights/presentation/insight_bar_chart.dart';
import 'package:ctrl_spend/features/insights/presentation/insight_chart_card.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_empty.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S20's 6 months view: the last six periods against the budget, each
/// full one coral when over budget and grey when under, the current one in
/// `ink` and "so far". The average, Under budget and Highest month use
/// full periods only. A period is named after the month it ends in, as in
/// the design (15 Oct – 14 Nov is "Nov"). With no spending in any of the
/// six it shows S40.
class InsightsTrendView extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final formatter = MoneyFormatter(currency);
    final budget = prefs.monthlyBudgetMinor;
    final trend = recentPeriods(
      ref.watch(transactionsProvider()).value ?? const [],
      today: ref.watch(clockProvider)(),
      startDay: prefs.monthStartDay,
      budgetMinor: budget,
    );
    if (trend.periods.every((p) => p.spentMinor == 0)) {
      return InsightsEmpty(currency: currency);
    }

    String short(Period p) => DateFormat('MMM', locale).format(p.end);
    String long(Period p) => DateFormat('MMMM', locale).format(p.end);

    final periodLabels = <String>[];
    final bars = <InsightBar>[];
    for (final p in trend.periods) {
      final month = long(p.period);
      final amount = formatter.format(p.spentMinor);
      periodLabels.add(switch (p.overBudget) {
        _ when p.soFar => l10n.periodSoFar(month, amount),
        false => l10n.periodUnderBudget(month, amount),
        true => l10n.periodOverBudget(month, amount),
        null => l10n.labelAmount(month, amount),
      });
      bars.add((
        label: short(p.period),
        valueMinor: p.spentMinor,
        color: p.soFar
            ? colors.ink
            : p.overBudget ?? false
            ? ChartPalette.over
            : colors.disabled,
      ));
    }

    final full = trend.full;
    final average = trend.averageMinor;
    final range = full.isEmpty
        ? null
        : full.length == 1
        ? short(full.single.period)
        : '${short(full.first.period)} – ${short(full.last.period)}';

    final underBudget = switch (trend.underBudgetCount) {
      final count? => (
        label: l10n.underBudget,
        value: l10n.countOfTotal(count, full.length),
        caption: l10n.fullMonths(full.length),
      ),
      null => null,
    };
    final highest = switch (trend.highest) {
      final p? => (
        label: l10n.highestMonth,
        value: formatter.formatCompact(p.spentMinor),
        caption: long(p.period),
      ),
      null => null,
    };

    final card = InsightChartCard(
      label: l10n.avgPerMonth,
      amount: average == null ? '—' : formatter.formatCompact(average),
      caption: range == null
          ? l10n.noFullMonths
          : l10n.fullMonthsRange(range, full.length),
      chip: budget == null
          ? null
          : l10n.budgetChip(formatter.formatCompact(budget)),
      chart: InsightBarChart(
        bars: bars,
        barWidth: 30,
        bubbleAmount: formatter.formatCompact(trend.periods.last.spentMinor),
        bubbleNote: l10n.soFar,
        reference: budget == null
            ? null
            : (valueMinor: budget, label: l10n.budgetLine, labelRight: true),
        semanticLabel: budget == null
            ? l10n.trendChartLabelNoBudget(periodLabels.join('; '))
            : l10n.trendChartLabel(
                formatter.format(budget),
                periodLabels.join('; '),
              ),
      ),
      legend: [
        if (budget != null) ...[
          (colors.disabled, l10n.underBudget),
          (ChartPalette.over, l10n.overBudget),
        ],
        (colors.ink, l10n.thisPeriod),
      ],
      stats: [?underBudget, ?highest],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        const SizedBox(height: AppSpacing.cardGap),
        const _ViewPastPeriods(),
      ],
    );
  }
}

/// Opens S25: `surface` with `ink` text in both themes.
class _ViewPastPeriods extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.r24),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => unawaited(context.push(Routes.pastPeriods)),
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.viewPastPeriods,
                  style: context.text.rowTitle.copyWith(color: colors.ink),
                ),
                const SizedBox(width: 6),
                ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
