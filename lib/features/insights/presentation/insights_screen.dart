import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/segmented_control.dart';
import 'package:ctrl_spend/features/insights/domain/insight_calculations.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_empty.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_month_view.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_trend_view.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_week_view.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InsightsRange { week, month, sixMonths }

/// S18–S20 Insights: Week · Month · 6 months, opening on Month. Until
/// there's spending on [minSpendingDays] days, every view is S40.
class InsightsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  InsightsRange _range = InsightsRange.month;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final enough = hasEnoughSpending(
      ref.watch(transactionsProvider()).value ?? const <Transaction>[],
    );
    final currency = Currency.fromCode(
      (ref.watch(preferencesProvider).value ?? const Preferences())
          .currencyCode,
    );
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
                _ when !enough => InsightsEmpty(currency: currency),
                InsightsRange.month => const InsightsMonthView(),
                InsightsRange.week => const InsightsWeekView(),
                InsightsRange.sixMonths => const InsightsTrendView(),
              },
            ],
          ),
        ),
      ),
    );
  }
}
