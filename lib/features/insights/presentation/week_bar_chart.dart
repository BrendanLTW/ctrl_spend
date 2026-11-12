import 'dart:math' as math;

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/features/insights/domain/insight_calculations.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// S19's daily bars: the last 7 days against the daily pace line, each bar
/// coral when over pace and grey when under, today in `ink` with its
/// amount above it. Without a [paceMinor] there's no line and every past
/// day is grey. Screen readers get every day's amount and result.
class WeekBarChart extends StatelessWidget {
  const new({
    required this.days,
    required this.paceMinor,
    required this.currency,
    super.key,
  });

  /// Oldest first; the last one is today.
  final List<DaySpend> days;
  final int? paceMinor;
  final Currency currency;

  static const double _barWidth = 26;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = MoneyFormatter(currency);
    final todayIndex = days.length - 1;
    final pace = paceMinor;

    final top = math.max(
      days.fold(0, (m, d) => math.max(m, d.spentMinor)),
      pace ?? 0,
    );
    // A short stub keeps quiet days visible; the label has the real value.
    final stub = top * 0.04;

    Color barColor(int i) {
      if (i == todayIndex) return colors.ink;
      return days[i].underPace ?? true ? colors.disabled : ChartPalette.over;
    }

    final dayLabels = [
      for (final (i, d) in days.indexed)
        _dayLabel(l10n, d, i == todayIndex, formatter, locale),
    ];
    final semanticLabel = pace == null
        ? l10n.weekChartLabelNoPace(dayLabels.join('; '))
        : l10n.weekChartLabel(formatter.format(pace), dayLabels.join('; '));

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: 230,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: top == 0 ? 1 : top.toDouble(),
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    final isToday = i == todayIndex;
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        DateFormat('EEE', locale).format(days[i].day),
                        style: text.rowTitleSm.copyWith(
                          color: isToday ? colors.ink : colors.muted,
                          fontWeight: isToday ? FontWeight.w700 : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                if (pace != null)
                  HorizontalLine(
                    y: pace.toDouble(),
                    color: colors.muted,
                    strokeWidth: 1.5,
                    dashArray: const [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      padding: const EdgeInsets.only(bottom: 10),
                      style: text.caption.copyWith(
                        color: colors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                      labelResolver: (_) => l10n.dailyPace,
                    ),
                  ),
              ],
            ),
            barTouchData: BarTouchData(
              enabled: false,
              handleBuiltInTouches: false,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => colors.ink,
                tooltipBorderRadius: BorderRadius.circular(16),
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                tooltipMargin: 12,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                      '${formatter.format(days[groupIndex].spentMinor)}\n',
                      text.caption.copyWith(
                        color: colors.onInk,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text: l10n.todayBubble,
                          style: text.labelSm.copyWith(
                            color: colors.onInk,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
            barGroups: [
              for (final (i, d) in days.indexed)
                BarChartGroupData(
                  x: i,
                  showingTooltipIndicators: [if (i == todayIndex) 0],
                  barRods: [
                    BarChartRodData(
                      toY: math.max(d.spentMinor.toDouble(), stub),
                      color: barColor(i),
                      width: _barWidth,
                      borderRadius: BorderRadius.circular(_barWidth / 2),
                    ),
                  ],
                ),
            ],
          ),
          duration: Duration.zero,
        ),
      ),
    );
  }

  String _dayLabel(
    AppLocalizations l10n,
    DaySpend d,
    bool isToday,
    MoneyFormatter formatter,
    String locale,
  ) {
    final day = DateFormat('EEEE', locale).format(d.day);
    final amount = formatter.format(d.spentMinor);
    if (isToday) return l10n.dayToday(day, amount);
    return switch (d.underPace) {
      true => l10n.dayUnderPace(day, amount),
      false => l10n.dayOverPace(day, amount),
      null => l10n.dayAmount(day, amount),
    };
  }
}
