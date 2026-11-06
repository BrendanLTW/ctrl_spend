import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_display.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:ctrl_spend/core/widgets/onboarding_scaffold.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S05 Set your monthly budget (step 3 of 5). Continue saves the amount;
/// Skip clears it and goes past S06, since there's nothing to split.
class BudgetScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late int _minor =
      ref.read(preferencesProvider).value?.monthlyBudgetMinor ?? 0;

  Future<void> _continue() async {
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(monthlyBudgetMinor: _minor));
    if (mounted) await context.push(Routes.onboardingCategories);
  }

  Future<void> _skip() async {
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(monthlyBudgetMinor: null));
    if (mounted) await context.push(Routes.onboardingSetup);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value;
    final currency = Currency.fromCode(prefs?.currencyCode ?? '');
    final formatter = MoneyFormatter(currency);
    // Limits set on S06 count when coming back here.
    final categories = ref.watch(categoriesProvider()).value ?? const [];
    final shortBy = limitsOverBudgetBy(
      categories: categories,
      budgetMinor: _minor,
    );
    return OnboardingScaffold(
      step: 3,
      title: l10n.budgetTitle,
      subtitle: l10n.budgetSubtitle,
      onSkip: _skip,
      primaryLabel: l10n.continueAction,
      onPrimary: _minor > 0 && shortBy == null ? _continue : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r32),
            ),
            child: Column(
              children: [
                AmountDisplay(
                  minor: _minor,
                  currency: currency,
                  label: l10n.monthlyBudget.toUpperCase(),
                  // The warning takes the caption's place, by the amount.
                  caption: shortBy == null ? l10n.perMonth : null,
                  semanticLabel: l10n.budgetPerMonthLabel(
                    formatter.format(_minor),
                  ),
                ),
                if (shortBy != null)
                  Text(
                    l10n.budgetBelowLimits(
                      formatter.formatCompact(allocated(categories)),
                    ),
                    textAlign: TextAlign.center,
                    style: context.text.caption.copyWith(
                      color: colors.negative,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      footer: MoneyKeypad(
        value: _minor,
        onChanged: (minor) => setState(() => _minor = minor),
      ),
    );
  }
}
