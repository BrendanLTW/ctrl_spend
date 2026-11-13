import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/core/widgets/stat_card.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_week_view.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'insights_screen_test.dart' show pumpInsights, spend;

/// RM 2,015 over the 31-day period 15 Oct – 14 Nov is RM 65 a day.
const budget = 201500;

/// The design's week, Thu 29 Oct to today, Wed 4 Nov: RM 356, only
/// Sunday over pace.
Future<void> designWeek() async {
  for (final (day, minor, title) in [
    (DateTime(2026, 10, 29, 12), 2240, 'Lunch'),
    (DateTime(2026, 10, 30, 12), 4800, 'Groceries'),
    (DateTime(2026, 10, 31, 12), 6000, 'Cinema'),
    (DateTime(2026, 11, 1, 12), 13900, 'TNB electricity'),
    (DateTime(2026, 11, 2, 12), 1590, 'Coffee'),
    (DateTime(2026, 11, 3, 12), 4000, 'Grab'),
    (DateTime(2026, 11, 4, 8), 3070, 'Breakfast'),
  ]) {
    await spend(minor, 'Food', at: day, title: title);
  }
}

Future<void> pumpWeek(
  WidgetTester tester, {
  int? budgetMinor = budget,
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed = designWeek,
}) async {
  await pumpInsights(tester, theme: theme, budget: budgetMinor, seed: seed);
  await tester.tap(find.text('Week'));
  await tester.pumpAndSettle();
}

List<Color> barColors(WidgetTester tester) => [
  for (final g in tester.widget<BarChart>(find.byType(BarChart)).data.barGroups)
    g.barRods.single.color!,
];

void main() {
  group('S19 Insights · Week', () {
    testWidgets('shows the total, range, average and pace', (tester) async {
      await pumpWeek(tester);
      expect(find.byType(InsightsWeekView), findsOneWidget);
      expect(find.text('LAST 7 DAYS'), findsOneWidget);
      expect(find.text('RM 356'), findsOneWidget);
      expect(find.text('29 Oct – 4 Nov · avg RM 50.86 a day'), findsOneWidget);
      expect(find.text('Pace RM 65/day'), findsOneWidget);
    });

    testWidgets('marks each day under or over pace, today in ink', (
      tester,
    ) async {
      await pumpWeek(tester, theme: AppTheme.light);
      const light = AppColors.light;
      expect(barColors(tester), [
        light.disabled,
        light.disabled,
        light.disabled,
        ChartPalette.over,
        light.disabled,
        light.disabled,
        light.ink,
      ]);
      final chart = tester.widget<BarChart>(find.byType(BarChart)).data;
      expect(chart.extraLinesData.horizontalLines.single.y, 6500);
      expect(chart.barGroups.last.showingTooltipIndicators, [0]);
      expect(find.text('Under pace'), findsWidgets);
      expect(find.text('Over pace'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('the chart reads every day to screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWeek(tester);
      expect(
        find.bySemanticsLabel(
          'Daily spending, pace RM 65.00 a day: '
          'Thursday RM 22.40, under pace; Friday RM 48.00, under pace; '
          'Saturday RM 60.00, under pace; Sunday RM 139.00, over pace; '
          'Monday RM 15.90, under pace; Tuesday RM 40.00, under pace; '
          'Wednesday RM 30.70, today',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('Under pace and Biggest day stats', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWeek(tester);
      expect(find.text('6 of 7'), findsOneWidget);
      expect(find.text('days this week'), findsOneWidget);
      expect(find.text('BIGGEST DAY'), findsOneWidget);
      expect(find.text('RM 139'), findsOneWidget);
      expect(find.text('Sun · TNB electricity'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Biggest day, RM 139 Sun · TNB electricity'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('without a budget there is no pace', (tester) async {
      await pumpWeek(tester, budgetMinor: null);
      expect(find.textContaining('Pace'), findsNothing);
      expect(find.text('Over pace'), findsNothing);
      expect(
        tester
            .widget<BarChart>(find.byType(BarChart))
            .data
            .extraLinesData
            .horizontalLines,
        isEmpty,
      );
      expect(find.byType(StatCard), findsOneWidget);
      expect(find.text('BIGGEST DAY'), findsOneWidget);
    });

    testWidgets('a week without spending shows S40', (tester) async {
      await pumpWeek(
        tester,
        // Spending before the 7 days doesn't count.
        seed: () => spend(5000, 'Food', at: DateTime(2026, 10, 28, 12)),
      );
      expect(find.text('Not enough data yet'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('Week uses the theme in ${theme.name} mode', (tester) async {
      await pumpWeek(tester, theme: theme);
      expect(barColors(tester).first, colors.disabled);
      expect(barColors(tester).last, colors.ink);
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(InsightsWeekView),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((card.decoration! as BoxDecoration).color, colors.surface);
    });
  }
}
