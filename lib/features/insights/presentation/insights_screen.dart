import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/segmented_control.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_month_view.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_week_view.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum InsightsRange { week, month, sixMonths }

/// S18–S20 Insights: Week · Month · 6 months, opening on Month.
class InsightsScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightsRange _range = InsightsRange.month;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          // Clear of the floating bottom bar (DESIGN §6).
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            16,
            AppSpacing.screenX,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.textX - AppSpacing.screenX,
                  0,
                  0,
                  12,
                ),
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.tabInsights,
                    style: text.welcomeTitle.copyWith(color: colors.ink),
                  ),
                ),
              ),
              SegmentedControl<InsightsRange>(
                segments: [
                  (value: InsightsRange.week, label: l10n.insightsWeek),
                  (value: InsightsRange.month, label: l10n.insightsMonth),
                  (
                    value: InsightsRange.sixMonths,
                    label: l10n.insightsSixMonths,
                  ),
                ],
                selected: _range,
                onChanged: (range) => setState(() => _range = range),
              ),
              switch (_range) {
                InsightsRange.month => const InsightsMonthView(),
                InsightsRange.week => const InsightsWeekView(),
                // shortcut: 6 months (S20) is task 3.4; until then it shows
                // nothing.
                InsightsRange.sixMonths => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
    );
  }
}
