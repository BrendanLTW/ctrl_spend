import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/budgets/presentation/category_budget_row.dart';
import 'package:ctrl_spend/features/budgets/presentation/monthly_budget_card.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S17 Budgets: the monthly budget and each category limit for this
/// period. Tapping either opens the keypad sheet; Add sets a limit on a
/// category that has none.
class BudgetsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final period = periodFor(ref.watch(clockProvider)(), prefs.monthStartDay);
    final inPeriod =
        ref.watch(transactionsProvider(period: period)).value ?? const [];
    final expense =
        ref
            .watch(
              categoriesProvider(
                type: TransactionType.expense,
                archived: false,
              ),
            )
            .value ??
        const <Category>[];
    final spent = spentByCategory(inPeriod, period);
    final limited = [
      for (final c in expense)
        if (c.limitMinor != null) c,
    ];
    final unlimited = [
      for (final c in expense)
        if (c.limitMinor == null) c,
    ];
    final budget = prefs.monthlyBudgetMinor;

    Future<void> editBudget() async {
      final allocatedMinor = allocated(expense);
      final result = await showAmountSheet(
        context,
        title: l10n.monthlyBudget,
        leading: const CategoryTile(
          icon: AppIcon.wallet,
          color: CategoryColorKey.neutral,
        ),
        currency: currency,
        initialMinor: budget ?? 0,
        removable: budget != null,
        minMinor: allocatedMinor,
        minMessage: l10n.budgetBelowLimits(
          MoneyFormatter(currency).formatCompact(allocatedMinor),
        ),
      );
      if (result == null) return;
      await ref
          .read(preferencesRepositoryProvider)
          .update(
            (p) => p.copyWith(
              monthlyBudgetMinor: switch (result) {
                AmountSaved(:final minor) => minor,
                AmountRemoved() => null,
              },
            ),
          );
    }

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
          categories: expense,
          budgetMinor: budget,
        ),
      );
      if (result == null) return;
      // Removing a limit keeps the category and its transactions.
      await ref
          .read(categoryRepositoryProvider)
          .update(
            category.copyWith(
              limitMinor: switch (result) {
                AmountSaved(:final minor) => minor,
                AmountRemoved() => null,
              },
            ),
          );
    }

    Future<void> addLimit() async {
      final picked = await showAppSheet<Category>(
        context,
        title: l10n.addLimitSheetTitle,
        builder: (sheet) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheet).height * 0.6,
          ),
          child: SingleChildScrollView(
            child: ListGroup(
              children: [
                for (final c in unlimited)
                  ListGroupRow(
                    leading: CategoryTile.forKey(c.iconKey, color: c.colorKey),
                    title: c.name,
                    onTap: () => Navigator.of(sheet).pop(c),
                  ),
              ],
            ),
          ),
        ),
      );
      if (picked != null && context.mounted) await editLimit(picked);
    }

    return Scaffold(
      backgroundColor: colors.ground,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.textX - AppSpacing.screenX,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.tabBudgets,
                      style: text.welcomeTitle.copyWith(color: colors.ink),
                    ),
                  ),
                  Text(
                    formatPeriod(period, locale).toUpperCase(),
                    style: text.label.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MonthlyBudgetCard(
              spentMinor: periodTotals(inPeriod, period).spentMinor,
              budgetMinor: budget,
              currency: currency,
              onTap: editBudget,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: AppSpacing.textX - AppSpacing.screenX),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.byCategory.toUpperCase(),
                      style: text.label.copyWith(color: colors.muted),
                    ),
                  ),
                ),
                if (unlimited.isNotEmpty)
                  TextButton.icon(
                    onPressed: addLimit,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      foregroundColor: colors.ink,
                      overlayColor: colors.raised,
                    ),
                    icon: AppIconView(AppIcon.add, size: 20, color: colors.ink),
                    label: Text(
                      l10n.add,
                      style: text.rowTitle.copyWith(color: colors.ink),
                    ),
                  )
                else
                  const SizedBox(height: 44),
              ],
            ),
            const SizedBox(height: 8),
            if (limited.isNotEmpty)
              ListGroup(
                children: [
                  for (final c in limited)
                    CategoryBudgetRow(
                      category: c,
                      spentMinor: spent[c.id] ?? 0,
                      currency: currency,
                      onTap: () => editLimit(c),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
