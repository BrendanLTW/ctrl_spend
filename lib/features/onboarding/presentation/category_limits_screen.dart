import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/onboarding_scaffold.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S06 Split by category (step 4 of 5): the allocated summary and a limit
/// per expense category, capped so they fit in the budget. Limits save as
/// they're set; Continue and Skip both move on.
class CategoryLimitsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value;
    final currency = Currency.fromCode(prefs?.currencyCode ?? '');
    final budgetMinor = prefs?.monthlyBudgetMinor;
    final categories =
        ref
            .watch(
              categoriesProvider(
                type: TransactionType.expense,
                archived: false,
              ),
            )
            .value ??
        const <Category>[];

    Future<void> editLimit(Category category) async {
      final result = await showAmountSheet(
        context,
        title: l10n.categoryBudget(category.name),
        leading: CategoryTile.forKey(
          category.iconKey,
          color: category.colorKey,
        ),
        currency: currency,
        initialMinor: category.limitMinor ?? 0,
        removable: category.limitMinor != null,
        maxMinor: maxLimitFor(
          category.id,
          categories: categories,
          budgetMinor: budgetMinor,
        ),
      );
      final limit = switch (result) {
        AmountSaved(:final minor) => minor,
        AmountRemoved() => null,
        null => category.limitMinor,
      };
      if (limit == category.limitMinor) return;
      await ref
          .read(categoryRepositoryProvider)
          .update(category.copyWith(limitMinor: limit));
    }

    void next() => context.push(Routes.onboardingReminders);
    return OnboardingScaffold(
      step: 4,
      title: l10n.splitTitle,
      subtitle: l10n.splitSubtitle,
      onSkip: next,
      primaryLabel: l10n.continueAction,
      onPrimary: next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (budgetMinor != null) ...[
            _AllocatedCard(
              allocatedMinor: allocated(categories),
              budgetMinor: budgetMinor,
              currency: currency,
            ),
            const SizedBox(height: AppSpacing.sectionTop),
          ],
          SectionLabel(l10n.categories),
          ListGroup(
            children: [
              for (final category in categories)
                _LimitRow(
                  category: category,
                  currency: currency,
                  onTap: () => editLimit(category),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllocatedCard extends StatelessWidget {
  const new({
    required this.allocatedMinor,
    required this.budgetMinor,
    required this.currency,
  });

  final int allocatedMinor;
  final int budgetMinor;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(currency);
    final share = budgetMinor == 0 ? 0.0 : allocatedMinor / budgetMinor;
    final flexibleMinor = budgetMinor - allocatedMinor;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SpreadOrStack(
            start: Text(
              l10n.allocated.toUpperCase(),
              style: text.label.copyWith(color: colors.muted),
            ),
            end: _AllocatedOf(
              allocated: formatter.formatCompact(allocatedMinor),
              budget: formatter.formatCompact(budgetMinor),
            ),
          ),
          const SizedBox(height: 14),
          AppProgressBar(
            value: share,
            semanticLabel: l10n.allocatedLabel((share * 100).floor()),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.flexibleRemainder(formatter.formatCompact(flexibleMinor)),
            style: text.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}

/// "RM 900 of RM 2,000" with the allocated figure bold.
class _AllocatedOf extends StatelessWidget {
  const new({required this.allocated, required this.budget});

  final String allocated;
  final String budget;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final full = context.l10n.allocatedOf(allocated, budget);
    final at = full.indexOf(allocated);
    return Text.rich(
      TextSpan(
        style: text.body.copyWith(color: colors.muted),
        children: [
          TextSpan(text: full.substring(0, at)),
          TextSpan(
            text: allocated,
            style: text.rowTitle.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: full.substring(at + allocated.length)),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  const new({
    required this.category,
    required this.currency,
    required this.onTap,
  });

  final Category category;
  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final limit = category.limitMinor;
    final amount = limit == null
        ? null
        : MoneyFormatter(currency).formatCompact(limit);
    return Semantics(
      button: true,
      label: amount == null
          ? l10n.categoryNoLimitLabel(category.name)
          : l10n.categoryLimitLabel(category.name, amount),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              CategoryTile.forKey(category.iconKey, color: category.colorKey),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category.name,
                  style: text.rowTitle.copyWith(color: colors.ink),
                ),
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: colors.fillSoft,
                  shape: const StadiumBorder(),
                ),
                child: amount == null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: colors.muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.addLimit,
                            style: text.rowTitleSm.copyWith(
                              color: colors.muted,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        amount,
                        style: text.rowTitleSm.copyWith(color: colors.ink),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
