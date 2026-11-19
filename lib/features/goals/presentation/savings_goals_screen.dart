import 'dart:async';

import 'package:ctrlspend/core/money/money_formatter.dart';
import 'package:ctrlspend/core/period/clock.dart';
import 'package:ctrlspend/core/period/period.dart';
import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:ctrlspend/core/theme/app_spacing.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/amount_text.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/category_tile.dart';
import 'package:ctrlspend/core/widgets/empty_state.dart';
import 'package:ctrlspend/core/widgets/large_text.dart';
import 'package:ctrlspend/core/widgets/list_group.dart';
import 'package:ctrlspend/core/widgets/section_label.dart';
import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/features/goals/domain/goal.dart';
import 'package:ctrlspend/features/goals/domain/goal_calculations.dart';
import 'package:ctrlspend/features/goals/domain/goal_repository.dart';
import 'package:ctrlspend/features/goals/presentation/goal_card.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S29 Savings goals: the total saved and this period's net, the active
/// goals, and the completed ones behind a row that expands. Goals never
/// change "Left to spend" (PRD §5.12).
class SavingsGoalsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends ConsumerState<SavingsGoalsScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final formatter = MoneyFormatter(currency);
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final goals = ref.watch(goalsProvider).value;
    final contributions =
        ref.watch(goalContributionsProvider).value ??
        const <GoalContribution>[];

    void addGoal() => unawaited(context.push(Routes.newGoal));
    void open(Goal goal) => unawaited(context.push(Routes.goal(goal.id)));

    final Widget body;
    if (goals == null) {
      body = const SizedBox.shrink();
    } else if (goals.isEmpty) {
      // S63.
      body = ListView(
        padding: const EdgeInsets.only(top: 170, bottom: 32),
        children: [
          EmptyState(
            card: false,
            icon: AppIcon.target,
            title: l10n.noGoalsTitle,
            body: l10n.noGoalsBody,
            actionLabel: l10n.addGoal,
            onAction: addGoal,
          ),
        ],
      );
    } else {
      final savedById = <int, int>{};
      for (final c in contributions) {
        savedById[c.goalId] = (savedById[c.goalId] ?? 0) + c.amountMinor;
      }
      int saved(Goal g) => savedById[g.id] ?? 0;
      final active = [
        for (final g in goals)
          if (goalStatus(g, saved(g), today) != GoalStatus.completed) g,
      ];
      // Most recently completed first.
      final completed =
          [
            for (final g in goals)
              if (goalStatus(g, saved(g), today) == GoalStatus.completed) g,
          ]..sort(
            (a, b) => (b.completedAt ?? b.targetMonth).compareTo(
              a.completedAt ?? a.targetMonth,
            ),
          );

      body = ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          8,
          AppSpacing.screenX,
          32,
        ),
        children: [
          _TotalCard(
            totalMinor: savedMinor(contributions),
            thisPeriodMinor: savedInPeriodMinor(
              contributions,
              periodFor(now, prefs.monthStartDay),
            ),
            currency: currency,
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionLabel(l10n.activeGoals),
            for (final (i, g) in active.indexed) ...[
              if (i > 0) const SizedBox(height: AppSpacing.cardGap),
              GoalCard(
                goal: g,
                savedMinor: saved(g),
                currency: currency,
                onTap: () => open(g),
              ),
            ],
          ],
          if (completed.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.cardGap),
            ListGroup(
              children: [
                ListGroupRow(
                  leading: const CategoryTile(
                    icon: AppIcon.check,
                    color: CategoryColorKey.green,
                  ),
                  title: l10n.completedGoals(completed.length),
                  subtitle: l10n.goalNameAmount(
                    completed.first.name,
                    formatter.formatCompact(completed.first.targetMinor),
                  ),
                  onTap: () => setState(() => _showCompleted = !_showCompleted),
                ),
              ],
            ),
            // The same cards as active goals, saying when each was done.
            if (_showCompleted)
              for (final g in completed) ...[
                const SizedBox(height: AppSpacing.cardGap),
                GoalCard(
                  goal: g,
                  savedMinor: saved(g),
                  currency: currency,
                  completedOn: g.completedAt?.toLocal() ?? g.targetMonth,
                  onTap: () => open(g),
                ),
              ],
          ],
        ],
      );
    }

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const AppIconView(
            AppIcon.chevronLeft,
            stroke: AppIconStroke.chevron,
            size: 30,
          ),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.savingsGoals,
          style: text.header.copyWith(color: colors.ink),
        ),
        actions: [
          TextButton(
            onPressed: addGoal,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              foregroundColor: colors.ink,
              overlayColor: colors.raised,
            ),
            child: Text(
              l10n.add,
              style: text.rowTitle.copyWith(color: colors.ink),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }
}

/// Total saved across every goal, and this period's net beside it.
class _TotalCard extends StatelessWidget {
  const new({
    required this.totalMinor,
    required this.thisPeriodMinor,
    required this.currency,
  });

  final int totalMinor;
  final int thisPeriodMinor;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final change = thisPeriodMinor == 0
        ? null
        : l10n.savedThisMonth(
            MoneyFormatter(currency).formatCompact(
              thisPeriodMinor,
              sign: thisPeriodMinor > 0 ? MoneySign.income : MoneySign.auto,
            ),
          );
    final total = MoneyFormatter(currency).format(totalMinor);
    return Semantics(
      container: true,
      label: [l10n.totalSaved, total, ?change].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.totalSaved.toUpperCase(),
              style: text.label.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 4),
            SpreadOrStack(
              start: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AmountText(
                  totalMinor,
                  currency: currency,
                  style: text.displaySm.copyWith(color: colors.ink),
                ),
              ),
              end: change == null
                  ? const SizedBox.shrink()
                  : Text(
                      change,
                      style: text.rowTitle.copyWith(
                        color: thisPeriodMinor > 0
                            ? colors.positive
                            : colors.negative,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
