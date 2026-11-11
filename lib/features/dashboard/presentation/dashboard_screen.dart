import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/budget_hero.dart';
import 'package:ctrl_spend/core/widgets/stat_card.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_header.dart';
import 'package:ctrl_spend/features/dashboard/presentation/recent_activities.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S09 Dashboard: what's left to spend this period, spent and income, and
/// the latest transactions. Every figure follows the stored data live.
class DashboardScreen extends ConsumerWidget {
  const new({super.key});

  static const recentCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final today = ref.watch(clockProvider)();
    final period = periodFor(today, prefs.monthStartDay);
    final inPeriod =
        ref.watch(transactionsProvider(period: period)).value ?? const [];
    final latest = ref.watch(transactionsProvider()).value ?? const [];
    final categories = <int, Category>{
      for (final c
          in ref.watch(categoriesProvider()).value ?? const <Category>[])
        c.id: c,
    };
    final totals = periodTotals(inPeriod, period);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      backgroundColor: context.colors.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Clear of the floating bottom bar.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            16,
            AppSpacing.screenX,
            120,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.textX - AppSpacing.screenX,
              ),
              child: DashboardHeader(
                periodLabel: formatPeriod(period, locale),
                name: prefs.userName,
                // shortcut: opens the inbox (S14) once task 3.9 builds it.
                onBell: () {},
                onAvatar: () => context.push(Routes.settings),
              ),
            ),
            const SizedBox(height: 20),
            BudgetHero(
              spentMinor: totals.spentMinor,
              budgetMinor: prefs.monthlyBudgetMinor,
              period: period,
              currency: currency,
              onTap: () => context.go(Routes.budgets),
              onSetBudget: () => context.go(Routes.budgets),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            Row(
              children: [
                Expanded(
                  child: _TotalCard(
                    label: l10n.spentLabel,
                    minor: totals.spentMinor,
                    currency: currency,
                    icon: Icons.arrow_upward_rounded,
                    tint: CategoryColorKey.red,
                  ),
                ),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: _TotalCard(
                    label: l10n.incomeLabel,
                    minor: totals.incomeMinor,
                    currency: currency,
                    icon: Icons.arrow_downward_rounded,
                    tint: CategoryColorKey.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            RecentActivities(
              transactions: latest.take(recentCount).toList(),
              categories: categories,
              currency: currency,
              today: today,
              onViewAll: () => context.go(Routes.activity),
              onOpen: (t) => context.push(Routes.transaction(t.id)),
              onAddFirst: () => context.push(Routes.add),
            ),
          ],
        ),
      ),
    );
  }
}

/// A Spent or Income card: "RM 760" with a smaller symbol, cents only
/// when they aren't .00.
class _TotalCard extends StatelessWidget {
  const new({
    required this.label,
    required this.minor,
    required this.currency,
    required this.icon,
    required this.tint,
  });

  final String label;
  final int minor;
  final Currency currency;
  final IconData icon;
  final CategoryColorKey tint;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final formatted = MoneyFormatter(currency).formatCompact(minor);
    final symbol = '${currency.symbol} ';
    return StatCard(
      label: label,
      semanticLabel: context.l10n.statLabel(label, formatted),
      icon: icon,
      iconColor: tint,
      value: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: symbol,
                style: text.rowTitleSm.copyWith(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: formatted.substring(symbol.length)),
            ],
          ),
        ),
      ),
    );
  }
}
