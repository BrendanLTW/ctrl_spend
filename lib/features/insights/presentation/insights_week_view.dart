import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
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
import 'package:intl/intl.dart';

/// S19's Week view: the last 7 days against the daily pace, each day
/// coral when over pace and grey when under, today in `ink`; then Under
/// pace and Biggest day. Without a budget the pace parts are left out.
/// With no spending in those days it shows S40.
class InsightsWeekView extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
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
    final todayIndex = week.days.length - 1;

    final dayLabels = <String>[];
    final bars = <InsightBar>[];
    for (final (i, d) in week.days.indexed) {
      final day = DateFormat('EEEE', locale).format(d.day);
      final amount = formatter.format(d.spentMinor);
      final isToday = i == todayIndex;
      dayLabels.add(switch (d.underPace) {
        _ when isToday => l10n.dayToday(day, amount),
        true => l10n.dayUnderPace(day, amount),
        false => l10n.dayOverPace(day, amount),
        null => l10n.labelAmount(day, amount),
      });
      bars.add((
        label: DateFormat('EEE', locale).format(d.day),
        valueMinor: d.spentMinor,
        color: isToday
            ? colors.ink
            : d.underPace ?? true
            ? colors.disabled
            : ChartPalette.over,
      ));
    }

    final underPace = switch (week.underPaceDays) {
      final count? => (
        label: l10n.underPace,
        value: l10n.countOfTotal(count, week.days.length),
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

    return InsightChartCard(
      label: l10n.last7Days,
      amount: formatter.formatCompact(week.totalMinor),
      caption: l10n.weekRangeAverage(
        formatPeriod(range, locale),
        formatter.formatCompact(week.averageMinor),
      ),
      chip: pace == null ? null : l10n.paceChip(formatter.formatCompact(pace)),
      chart: InsightBarChart(
        bars: bars,
        bubbleAmount: formatter.format(week.days.last.spentMinor),
        bubbleNote: l10n.todayBubble,
        reference: pace == null
            ? null
            : (valueMinor: pace, label: l10n.dailyPace, labelRight: false),
        semanticLabel: pace == null
            ? l10n.weekChartLabelNoPace(dayLabels.join('; '))
            : l10n.weekChartLabel(formatter.format(pace), dayLabels.join('; ')),
      ),
      legend: [
        if (pace != null) ...[
          (colors.disabled, l10n.underPace),
          (ChartPalette.over, l10n.overPace),
        ],
        (colors.ink, l10n.today),
      ],
      stats: [?underPace, ?biggestDay],
    );
  }
}
