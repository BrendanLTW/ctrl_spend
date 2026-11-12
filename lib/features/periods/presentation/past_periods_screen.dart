import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/periods/domain/period_summary.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S25 Past periods: the current period with days left and progress, then
/// every previous period back to the first transaction, newest first,
/// with its result against the budget. A row opens S26.
class PastPeriodsScreen extends ConsumerWidget {
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
    final budget = prefs.monthlyBudgetMinor;
    final today = ref.watch(clockProvider)();
    final transactions =
        ref.watch(transactionsProvider()).value ?? const <Transaction>[];

    DateTime? first;
    for (final t in transactions) {
      if (first == null || t.occurredAt.isBefore(first)) first = t.occurredAt;
    }
    final current = periodFor(today, prefs.monthStartDay);
    final spentNow = periodTotals(transactions, current).spentMinor;
    final previous = [
      for (final p in previousPeriods(
        today: today,
        startDay: prefs.monthStartDay,
        since: first,
      ))
        periodSummary(
          transactions,
          period: p,
          categories: const [],
          budgetMinor: budget,
        ),
    ];

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.pastPeriods,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          8,
          AppSpacing.screenX,
          32,
        ),
        children: [
          _CurrentPeriodCard(
            range: formatPeriod(current, locale),
            daysLeft: l10n.periodDaysLeft(daysLeft(current, today)),
            spentMinor: spentNow,
            budgetMinor: budget,
            formatter: formatter,
          ),
          if (previous.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionLabel(l10n.previousPeriods),
            ListGroup(
              children: [
                for (final s in previous)
                  ListGroupRow(
                    title: formatPeriod(s.period, locale),
                    subtitle: budget == null
                        ? l10n.amountSpent(
                            formatter.formatCompact(s.spentMinor),
                          )
                        : l10n.spentOfAmount(
                            formatter.formatCompact(s.spentMinor),
                            formatter.formatCompact(budget),
                          ),
                    value: switch (s.leftMinor) {
                      null => null,
                      final left when left > 0 => l10n.amountUnder(
                        formatter.formatCompact(left),
                      ),
                      final left => l10n.overBy(formatter.formatCompact(-left)),
                    },
                    valueColor: (s.leftMinor ?? 0) > 0
                        ? colors.positive
                        : colors.negative,
                    onTap: () =>
                        unawaited(context.push(Routes.period(s.period.start))),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrentPeriodCard extends StatelessWidget {
  const new({
    required this.range,
    required this.daysLeft,
    required this.spentMinor,
    required this.budgetMinor,
    required this.formatter,
  });

  final String range;
  final String daysLeft;
  final int spentMinor;
  final int? budgetMinor;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final budget = budgetMinor;
    final spent = budget == null
        ? l10n.amountSpent(formatter.formatCompact(spentMinor))
        : l10n.spentOfBudget(
            formatter.formatCompact(spentMinor),
            formatter.formatCompact(budget),
          );
    return Semantics(
      container: true,
      label: '${l10n.currentPeriod}, $range, $daysLeft, $spent',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.currentPeriod.toUpperCase(),
              style: text.label.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    range,
                    style: text.header.copyWith(color: colors.ink),
                  ),
                ),
                Text(daysLeft, style: text.body.copyWith(color: colors.muted)),
              ],
            ),
            if (budget != null) ...[
              const SizedBox(height: 18),
              AppProgressBar(
                value: spentMinor / budget,
                color: switch (budgetStatus(
                  spentMinor: spentMinor,
                  limitMinor: budget,
                )) {
                  BudgetStatus.warning => colors.warning,
                  BudgetStatus.negative => colors.negative,
                  BudgetStatus.neutral || BudgetStatus.noBudget => null,
                },
                semanticLabel: spent,
              ),
            ],
            const SizedBox(height: 14),
            Text(spent, style: text.body.copyWith(color: colors.muted)),
          ],
        ),
      ),
    );
  }
}
