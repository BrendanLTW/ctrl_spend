import 'dart:math' as math;

import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

typedef InsightBar = ({String label, int valueMinor, Color color});

typedef ReferenceLine = ({int valueMinor, String label, bool labelRight});

/// S19 and S20's bars against a dashed reference line (daily pace,
/// budget). The last bar is the current one: its label is bold and
/// [bubbleAmount] / [bubbleNote] float above it ("RM 30.70 / today").
/// Read by screen readers as [semanticLabel] alone.
class InsightBarChart extends StatelessWidget {
  const new({
    required this.bars,
    required this.bubbleAmount,
    required this.bubbleNote,
    required this.semanticLabel,
    this.reference,
    this.barWidth = 26,
    super.key,
  });

  /// Oldest first; the last one is the current one.
  final List<InsightBar> bars;
  final String bubbleAmount;
  final String bubbleNote;
  final String semanticLabel;
  final ReferenceLine? reference;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final current = bars.length - 1;
    final line = reference;

    final top = math.max(
      bars.fold(0, (m, b) => math.max(m, b.valueMinor)),
      line?.valueMinor ?? 0,
    );
    // A short stub keeps quiet bars visible; the label has the real value.
    final stub = top * 0.04;
    final lineLabelStyle = text.caption.copyWith(
      color: colors.muted,
      fontWeight: FontWeight.w600,
    );

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        height: 250,
        // Room above the chart for the line's label and the bubble.
        padding: const EdgeInsets.only(top: 20),
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
                    final isCurrent = value.toInt() == current;
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        bars[value.toInt()].label,
                        style: text.rowTitleSm.copyWith(
                          color: isCurrent ? colors.ink : colors.muted,
                          fontWeight: isCurrent ? FontWeight.w700 : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                if (line != null)
                  HorizontalLine(
                    y: line.valueMinor.toDouble(),
                    color: colors.muted,
                    strokeWidth: 1.5,
                    dashArray: const [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: line.labelRight
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      padding: const EdgeInsets.only(bottom: 10),
                      style: lineLabelStyle,
                      labelResolver: (_) => line.label,
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
                      '$bubbleAmount\n',
                      text.caption.copyWith(
                        color: colors.onInk,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text: bubbleNote,
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
              for (final (i, b) in bars.indexed)
                BarChartGroupData(
                  x: i,
                  showingTooltipIndicators: [if (i == current) 0],
                  barRods: [
                    BarChartRodData(
                      toY: math.max(b.valueMinor.toDouble(), stub),
                      color: b.color,
                      width: barWidth,
                      borderRadius: BorderRadius.circular(barWidth / 2),
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
}
