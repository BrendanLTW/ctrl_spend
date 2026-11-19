import 'dart:async';

import 'package:ctrlspend/core/money/money_formatter.dart';
import 'package:ctrlspend/core/period/clock.dart';
import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:ctrlspend/core/theme/app_spacing.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/theme/category_palette.dart';
import 'package:ctrlspend/core/widgets/action_sheet.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/app_progress_bar.dart';
import 'package:ctrlspend/core/widgets/category_tile.dart';
import 'package:ctrlspend/core/widgets/large_text.dart';
import 'package:ctrlspend/core/widgets/list_group.dart';
import 'package:ctrlspend/core/widgets/primary_button.dart';
import 'package:ctrlspend/core/widgets/section_label.dart';
import 'package:ctrlspend/core/widgets/text_link.dart';
import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/features/goals/domain/goal.dart';
import 'package:ctrlspend/features/goals/domain/goal_calculations.dart';
import 'package:ctrlspend/features/goals/domain/goal_repository.dart';
import 'package:ctrlspend/features/goals/presentation/contribution_sheet.dart';
import 'package:ctrlspend/features/goals/presentation/goal_style.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum _GoalOption { edit, complete, delete }

/// S30 Goal detail: saved of the target, where it stands and what to save
/// each month, the contributions, and Add money and Withdraw (S60/S61).
/// ••• opens S62.
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
    final now = ref.read(clockProvider)();
    final result = await showContributionSheet(
      context,
      goalName: goal.name,
      currency: currency,
      savedMinor: savedMinor,
      today: DateTime(now.year, now.month, now.day),
      withdraw: withdraw,
    );
    if (result == null) return;
    final repository = ref.read(goalRepositoryProvider);
    if (result.withdraw) {
      await repository.withdraw(
        goal.id,
        amountMinor: result.amountMinor,
        label: result.label.isEmpty ? l10n.contributionWithdrawn : result.label,
        date: result.date,
      );
    } else {
      await repository.addMoney(
        goal.id,
        amountMinor: result.amountMinor,
        label: result.label.isEmpty ? l10n.contributionAdded : result.label,
        date: result.date,
      );
    }
  }

  /// S62: Edit goal, Mark as completed (until it is), Delete goal.
  Future<void> _options(
    BuildContext context,
    WidgetRef ref, {
    required Goal goal,
    required bool completed,
    required int contributions,
  }) async {
    final l10n = context.l10n;
    final choice = await showActionSheet<_GoalOption>(
      context,
      title: goal.name,
      items: [
        (
          value: _GoalOption.edit,
          tile: const CategoryTile(
            icon: AppIcon.note,
            color: CategoryColorKey.blue,
          ),
          title: l10n.editGoal,
          subtitle: l10n.editGoalDetail,
          destructive: false,
        ),
        if (!completed)
          (
            value: _GoalOption.complete,
            tile: const CategoryTile(
              icon: AppIcon.check,
              color: CategoryColorKey.green,
            ),
            title: l10n.markGoalCompleted,
            subtitle: l10n.markGoalCompletedDetail,
            destructive: false,
          ),
        (
          value: _GoalOption.delete,
          tile: const CategoryTile(
            icon: AppIcon.trash,
            color: CategoryColorKey.red,
          ),
          title: l10n.deleteGoal,
          subtitle: l10n.deleteGoalDetail(contributions),
          destructive: true,
        ),
      ],
    );
    if (choice == null || !context.mounted) return;
    final repository = ref.read(goalRepositoryProvider);
    switch (choice) {
      case _GoalOption.edit:
        unawaited(context.push(Routes.editGoal(goal.id)));
      case _GoalOption.complete:
        await repository.markCompleted(goal.id, at: ref.read(clockProvider)());
        if (context.mounted) context.pop();
      // The sheet already says what goes, so there's no second dialog.
      case _GoalOption.delete:
        context.pop();
        await repository.delete(goal.id);
    }
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
              onPressed: () => _options(
                context,
                ref,
                goal: goal,
                completed:
                    goalStatus(goal, saved, today) == GoalStatus.completed,
                contributions: contributions.length,
              ),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: colors.ink,
                overlayColor: colors.raised,
              ),
              child: Semantics(
                label: l10n.goalOptions,
                excludeSemantics: true,
                child: Text(
                  '•••',
                  style: text.header.copyWith(
                    color: colors.ink,
                    letterSpacing: 1,
                  ),
                ),
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
        AppIcon.wallet,
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
        AppIcon.circleAlert,
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
