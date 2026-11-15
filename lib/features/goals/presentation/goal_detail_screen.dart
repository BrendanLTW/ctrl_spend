import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:ctrl_spend/features/goals/domain/goal_calculations.dart';
import 'package:ctrl_spend/features/goals/domain/goal_repository.dart';
import 'package:ctrl_spend/features/goals/presentation/contribution_sheet.dart';
import 'package:ctrl_spend/features/goals/presentation/goal_style.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S30 Goal detail: saved of the target, where it stands and what to save
/// each month, the contributions, and Add money and Withdraw. Edit opens
/// S31.
class GoalDetailScreen extends ConsumerWidget {
  const new({required this.goalId, super.key});

  final int goalId;

  Future<void> _contribute(
    BuildContext context,
    WidgetRef ref, {
    required Goal goal,
    required Currency currency,
    required int savedMinor,
    required bool withdraw,
  }) async {
    final l10n = context.l10n;
    final result = await showContributionSheet(
      context,
      title: withdraw ? l10n.withdraw : l10n.addMoney,
      currency: currency,
      maxMinor: withdraw ? savedMinor : null,
    );
    if (result == null) return;
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final repository = ref.read(goalRepositoryProvider);
    if (withdraw) {
      await repository.withdraw(
        goal.id,
        amountMinor: result.amountMinor,
        label: result.note.isEmpty ? l10n.contributionWithdrawn : result.note,
        date: today,
      );
    } else {
      await repository.addMoney(
        goal.id,
        amountMinor: result.amountMinor,
        label: result.note.isEmpty ? l10n.contributionAdded : result.note,
        date: today,
      );
    }
  }

  Future<void> _edit(BuildContext context) async {
    final deleted = await context.push<bool>(Routes.editGoal(goalId));
    if ((deleted ?? false) && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency = Currency.fromCode(
      ref.watch(preferencesProvider).value?.currencyCode ?? '',
    );
    final formatter = MoneyFormatter(currency);
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final goal = ref
        .watch(goalsProvider)
        .value
        ?.where((g) => g.id == goalId)
        .firstOrNull;
    final contributions = [
      for (final c
          in ref.watch(goalContributionsProvider).value ??
              const <GoalContribution>[])
        if (c.goalId == goalId) c,
    ];
    final saved = savedMinor(contributions);

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
          goal?.name ?? '',
          style: text.header.copyWith(color: colors.ink),
        ),
        actions: [
          if (goal != null)
            TextButton(
              onPressed: () => _edit(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                foregroundColor: colors.ink,
                overlayColor: colors.raised,
              ),
              child: Text(
                l10n.editAction,
                style: text.rowTitle.copyWith(color: colors.ink),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: goal == null
          ? const SizedBox.shrink()
          : SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenX,
                        8,
                        AppSpacing.screenX,
                        16,
                      ),
                      children: [
                        _GoalHero(
                          goal: goal,
                          savedMinor: saved,
                          currency: currency,
                        ),
                        const SizedBox(height: AppSpacing.cardGap),
                        _StatusCard(
                          goal: goal,
                          savedMinor: saved,
                          today: today,
                          currency: currency,
                        ),
                        const SizedBox(height: 28),
                        SectionLabel(l10n.contributions),
                        if (contributions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.textX - AppSpacing.screenX,
                            ),
                            child: Text(
                              l10n.noContributions,
                              style: text.body.copyWith(color: colors.muted),
                            ),
                          )
                        else
                          ListGroup(
                            children: [
                              for (final c in contributions)
                                ListGroupRow(
                                  title: c.label,
                                  subtitle: DateFormat(
                                    'd MMM',
                                    locale,
                                  ).format(c.date),
                                  value: formatter.formatCompact(
                                    c.amountMinor,
                                    sign: c.amountMinor > 0
                                        ? MoneySign.income
                                        : MoneySign.auto,
                                  ),
                                  valueColor: c.amountMinor > 0
                                      ? colors.positive
                                      : colors.ink,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenX,
                      0,
                      AppSpacing.screenX,
                      4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButton(
                          label: l10n.addMoney,
                          onPressed: () => _contribute(
                            context,
                            ref,
                            goal: goal,
                            currency: currency,
                            savedMinor: saved,
                            withdraw: false,
                          ),
                        ),
                        Center(
                          child: TextLink(
                            label: l10n.withdraw,
                            onPressed: saved > 0
                                ? () => _contribute(
                                    context,
                                    ref,
                                    goal: goal,
                                    currency: currency,
                                    savedMinor: saved,
                                    withdraw: true,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// The dark card: icon, "Saved RM 3,200 of RM 5,000", the bar, what's to
/// go and the target month. Dark in both themes, like the dashboard hero.
class _GoalHero extends StatelessWidget {
  const new({
    required this.goal,
    required this.savedMinor,
    required this.currency,
  });

  final Goal goal;
  final int savedMinor;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    const onHero = AppColors.dark;
    final formatter = MoneyFormatter(currency);
    final progress = goalProgress(goal, savedMinor);
    final saved = formatter.formatCompact(savedMinor);
    final target = formatter.formatCompact(goal.targetMinor);
    final toGo = l10n.goalToGo(
      formatter.formatCompact(toGoMinor(goal, savedMinor)),
    );
    final month = l10n.goalTarget(
      DateFormat('MMM y', locale).format(goal.targetMonth),
    );
    final footer = text.body.copyWith(
      color: onHero.ink,
      fontWeight: FontWeight.w500,
    );
    return Semantics(
      container: true,
      label: [
        l10n.goalSavedLabel,
        saved,
        l10n.goalOfTarget(target),
        toGo,
        month,
      ].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.colors.hero,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: onHero.raised,
                    shape: BoxShape.circle,
                  ),
                  child: AppIconView(
                    categoryIcon(goal.iconKey),
                    size: 24,
                    color: onHero.ink,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.goalSavedLabel.toUpperCase(),
                        style: text.label.copyWith(color: onHero.chipText),
                      ),
                      // One line, as on S30; scales down rather than wrap.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              saved,
                              style: text.amount.copyWith(color: onHero.ink),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.goalOfTarget(target),
                              style: text.rowTitle.copyWith(
                                color: onHero.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppProgressBar(
              value: progress,
              onHero: true,
              color: CategoryColors.dark.of(goalColour(goal.iconKey)).icon,
              semanticLabel: '',
            ),
            const SizedBox(height: 14),
            SpreadOrStack(
              start: Text(toGo, style: footer),
              end: Text(month, style: footer),
            ),
          ],
        ),
      ),
    );
  }
}

/// On track and the monthly amount, the target month here, or reached.
class _StatusCard extends StatelessWidget {
  const new({
    required this.goal,
    required this.savedMinor,
    required this.today,
    required this.currency,
  });

  final Goal goal;
  final int savedMinor;
  final DateTime today;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = MoneyFormatter(currency);
    final (icon, colour, title, body) = switch (goalStatus(
      goal,
      savedMinor,
      today,
    )) {
      GoalStatus.onTrack => (
        AppIcon.trendUp,
        CategoryColorKey.green,
        l10n.goalOnTrack,
        l10n.goalOnTrackBody(
          formatter.formatCompact(monthlyNeedMinor(goal, savedMinor, today)),
          DateFormat.MMMM(locale).format(goal.targetMonth),
        ),
      ),
      GoalStatus.behind => (
        AppIcon.warning,
        CategoryColorKey.orange,
        l10n.goalBehind,
        l10n.goalBehindBody(
          formatter.formatCompact(monthlyNeedMinor(goal, savedMinor, today)),
          DateFormat.MMMM(locale).format(goal.targetMonth),
        ),
      ),
      GoalStatus.pastTarget => (
        AppIcon.warning,
        CategoryColorKey.red,
        l10n.goalPastTarget,
        l10n.goalPastTargetBody(
          formatter.formatCompact(toGoMinor(goal, savedMinor)),
        ),
      ),
      GoalStatus.completed => (
        AppIcon.check,
        CategoryColorKey.green,
        l10n.goalCompleted,
        l10n.goalCompletedBody(formatter.formatCompact(goal.targetMinor)),
      ),
    };
    return Semantics(
      container: true,
      label: '$title, $body',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r28),
        ),
        child: Row(
          children: [
            CategoryTile(icon: icon, color: colour),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.rowTitle.copyWith(color: colors.ink)),
                  Text(body, style: text.body.copyWith(color: colors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
