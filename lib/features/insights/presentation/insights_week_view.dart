import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/core/widgets/stat_card.dart';
import 'package:ctrl_spend/features/insights/domain/insight_calculations.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_empty.dart';
import 'package:ctrl_spend/features/insights/presentation/week_bar_chart.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// S19's Week view: the last 7 days against the daily pace, then Under
/// pace and Biggest day. With no spending in those days it shows S40.
class InsightsWeekView extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final formatter = MoneyFormatter(currency);
    final today = ref.watch(clockProvider)();
    final budget = prefs.monthlyBudgetMinor;
    final week = lastSevenDays(
      ref.watch(transactionsProvider()).value ?? const [],
      today: today,
      startDay: prefs.monthStartDay,
      budgetMinor: budget,
    );
    if (week.totalMinor == 0) return InsightsEmpty(currency: currency);

    final pace = dailyPace(
      period: periodFor(today, prefs.monthStartDay),
      budgetMinor: budget,
    );
    final range = (start: week.days.first.day, end: week.days.last.day);

    final underPace = switch (week.underPaceDays) {
      final count? => (
        label: l10n.underPace,
        value: l10n.underPaceDays(count, week.days.length),
        caption: l10n.daysThisWeek,
      ),
      null => null,
    };
    final biggestDay = switch (week.biggestDay) {
      final day? => (
        label: l10n.biggestDay,
        value: formatter.formatCompact(day.spentMinor),
        caption: l10n.biggestDayCaption(
          DateFormat('EEE', locale).format(day.day),
          day.largest!.title,
        ),
      ),
      null => null,
    };
    final stats = <_Stat>[?underPace, ?biggestDay];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.last7Days.toUpperCase(),
                          style: text.label.copyWith(color: colors.muted),
                        ),
                        Text(
                          formatter.formatCompact(week.totalMinor),
                          style: text.amount.copyWith(color: colors.ink),
                        ),
                        Text(
                          l10n.weekRangeAverage(
                            formatPeriod(range, locale),
                            formatter.formatCompact(week.averageMinor),
                          ),
                          style: text.body.copyWith(color: colors.muted),
                        ),
                      ],
                    ),
                  ),
                  if (pace != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.raised,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        l10n.paceChip(formatter.formatCompact(pace)),
                        style: text.caption.copyWith(
                          color: colors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              WeekBarChart(
                days: week.days,
                paceMinor: pace,
                currency: currency,
              ),
              const SizedBox(height: 16),
              ExcludeSemantics(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (pace != null) ...[
                      _LegendDot(colors.disabled, l10n.underPace),
                      _LegendDot(ChartPalette.over, l10n.overPace),
                    ],
                    _LegendDot(colors.ink, l10n.today),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, stat) in stats.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.cardGap),
              Expanded(
                child: StatCard(
                  label: stat.label,
                  value: Text(stat.value),
                  caption: stat.caption,
                  semanticLabel: l10n.statCaptionLabel(
                    stat.label,
                    stat.value,
                    stat.caption,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

typedef _Stat = ({String label, String value, String caption});

class _LegendDot extends StatelessWidget {
  const new(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: context.text.caption.copyWith(color: context.colors.muted),
      ),
    ],
  );
}
