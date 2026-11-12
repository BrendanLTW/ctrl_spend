import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/day_selector.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/onboarding_scaffold.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/currency_names.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S04 Set up your month (step 2 of 5): currency, month start and a live
/// preview of the current period. Choices are saved as they're made.
class MonthSetupScreen extends ConsumerWidget {
  const new({super.key});

  /// The quick choices; any other start day shows as "Other".
  static const quickDays = [1, 15, 25];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final startDay = prefs.monthStartDay;
    final selectedQuick = switch (startDay) {
      DayOfMonth(:final day) when quickDays.contains(day) => day,
      _ => null,
    };
    final today = ref.watch(clockProvider)();
    final period = periodFor(today, startDay);
    final locale = Localizations.localeOf(context).toLanguageTag();

    void choose(int day) => ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(monthStartDay: DayOfMonth(day)));

    return OnboardingScaffold(
      step: 2,
      title: l10n.monthTitle,
      subtitle: l10n.monthSubtitle,
      primaryLabel: l10n.continueAction,
      onPrimary: () => context.push(Routes.onboardingBudget),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(l10n.currency),
          ListGroup(
            children: [
              ListGroupRow(
                leading: const CategoryTile(
                  icon: Icons.attach_money_rounded,
                  color: CategoryColorKey.green,
                ),
                title: l10n.currencyName(currency),
                value: currency.symbol,
                onTap: () => context.push(Routes.onboardingCurrency),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionTop),
          SectionLabel(l10n.monthStartsOn),
          Row(
            children: [
              for (final (i, (day, label)) in [
                (1, l10n.startDay1st),
                (15, l10n.startDay15th),
                (25, l10n.startDay25th),
              ].indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: DaySelector(
                    label: label,
                    selected: selectedQuick == day,
                    onTap: () => choose(day),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: DaySelector(
                  label: l10n.startDayOther,
                  selected: selectedQuick == null,
                  onTap: () => context.push(Routes.onboardingMonthStart),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListGroup(
            children: [
              ListGroupRow(
                leading: const CategoryTile(
                  icon: Icons.calendar_today_outlined,
                  color: CategoryColorKey.blue,
                ),
                title: l10n.currentPeriod,
                subtitle: l10n.periodWithDaysLeft(
                  formatPeriod(period, locale),
                  l10n.periodDaysLeft(daysLeft(period, today)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
