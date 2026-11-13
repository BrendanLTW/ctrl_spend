import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/core/widgets/stat_card.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_trend_view.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'insights_screen_test.dart' show pumpInsights, spend;

/// The design's six periods (start day 15, today 4 Nov): Jun – Oct are
/// full, only Oct over the RM 2,000 budget, and Nov is RM 760 so far.
Future<void> designTrend() async {
  for (final (month, minor) in [
    (6, 170000),
    (7, 182000),
    (8, 165000),
    (9, 175000),
    (10, 201000),
  ]) {
    await spend(minor, 'Food', at: DateTime(2026, month, 1, 12));
  }
  await spend(76000, 'Food', at: DateTime(2026, 11, 2, 12));
}

Future<void> pumpTrend(
  WidgetTester tester, {
  int? budget = 200000,
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed = designTrend,
}) async {
  await pumpInsights(tester, theme: theme, budget: budget, seed: seed);
  await tester.tap(find.text('6 months'));
  await tester.pumpAndSettle();
}

BarChartData chart(WidgetTester tester) =>
    tester.widget<BarChart>(find.byType(BarChart)).data;

List<Color> barColors(WidgetTester tester) => [
  for (final g in chart(tester).barGroups) g.barRods.single.color!,
];

void main() {
  group('S20 Insights · 6 months', () {
    testWidgets('averages full months only', (tester) async {
      await pumpTrend(tester);
      expect(find.byType(InsightsTrendView), findsOneWidget);
      expect(find.text('AVG PER MONTH'), findsOneWidget);
      // (1,700 + 1,820 + 1,650 + 1,750 + 2,010) / 5; Nov's 760 is left out.
      expect(find.text('RM 1,786'), findsOneWidget);
      expect(find.text('Jun – Oct, full months'), findsOneWidget);
      expect(find.text('Budget RM 2,000'), findsOneWidget);
    });

    testWidgets('marks months under or over, this period in ink', (
      tester,
    ) async {
      await pumpTrend(tester, theme: AppTheme.light);
      const light = AppColors.light;
      expect(barColors(tester), [
        light.disabled,
        light.disabled,
        light.disabled,
        light.disabled,
        ChartPalette.over,
        light.ink,
      ]);
      expect(chart(tester).extraLinesData.horizontalLines.single.y, 200000);
      expect(chart(tester).barGroups.last.showingTooltipIndicators, [0]);
      expect(find.text('Under budget'), findsOneWidget);
      expect(find.text('Over budget'), findsOneWidget);
      expect(find.text('This period'), findsOneWidget);
    });

    testWidgets('the chart reads every month to screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpTrend(tester);
      expect(
        find.bySemanticsLabel(
          'Monthly spending, budget RM 2,000.00: '
          'June RM 1,700.00, under budget; July RM 1,820.00, under budget; '
          'August RM 1,650.00, under budget; '
          'September RM 1,750.00, under budget; '
          'October RM 2,010.00, over budget; November RM 760.00, so far',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('Under budget and Highest month', (tester) async {
      await pumpTrend(tester);
      expect(find.text('UNDER BUDGET'), findsOneWidget);
      expect(find.text('4 of 5'), findsOneWidget);
      expect(find.text('full months'), findsOneWidget);
      expect(find.text('HIGHEST MONTH'), findsOneWidget);
      expect(find.text('RM 2,010'), findsOneWidget);
      expect(find.text('October'), findsOneWidget);
    });

    testWidgets('months before the first transaction are not full', (
      tester,
    ) async {
      await pumpTrend(
        tester,
        seed: () async {
          await spend(150000, 'Food', at: DateTime(2026, 10, 1, 12));
          await spend(76000, 'Food', at: DateTime(2026, 11, 2, 12));
        },
      );
      expect(find.text('RM 1,500'), findsWidgets);
      expect(find.text('Oct, full month'), findsOneWidget);
      expect(find.text('1 of 1'), findsOneWidget);
      expect(find.text('full month'), findsOneWidget);
    });

    testWidgets('no full month yet: only the current bar counts', (
      tester,
    ) async {
      await pumpTrend(
        tester,
        seed: () => spend(76000, 'Food', at: DateTime(2026, 11, 2, 12)),
      );
      expect(find.text('—'), findsOneWidget);
      expect(find.text('No full months yet'), findsOneWidget);
      expect(find.byType(StatCard), findsNothing);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('without a budget there is no line or count', (tester) async {
      await pumpTrend(tester, budget: null);
      expect(find.textContaining('Budget RM'), findsNothing);
      expect(find.text('Over budget'), findsNothing);
      expect(chart(tester).extraLinesData.horizontalLines, isEmpty);
      expect(find.text('UNDER BUDGET'), findsNothing);
      expect(find.text('HIGHEST MONTH'), findsOneWidget);
    });

    testWidgets('six months without spending show S40', (tester) async {
      await pumpTrend(
        tester,
        // Seven periods back, outside the chart.
        seed: () => spend(5000, 'Food', at: DateTime(2026, 4, 20, 12)),
      );
      expect(find.text('Not enough data yet'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('6 months uses the theme in ${theme.name} mode', (
      tester,
    ) async {
      await pumpTrend(tester, theme: theme);
      expect(barColors(tester).first, colors.disabled);
      expect(barColors(tester).last, colors.ink);
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(InsightsTrendView),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((card.decoration! as BoxDecoration).color, colors.surface);
    });
  }
}
