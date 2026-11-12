import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/categories/presentation/category_edit_sheets.dart';
import 'package:ctrl_spend/features/categories/presentation/category_period_card.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/date_labels.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S23 Category detail: this period against the limit, the Name, Icon &
/// colour and Monthly limit settings, recent transactions, and Archive
/// (or Restore). Income categories have no limit.
class CategoryDetailScreen extends ConsumerWidget {
  const new({required this.categoryId, super.key});

  final int categoryId;

  static const _recentCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final formatter = MoneyFormatter(currency);
    final today = ref.watch(clockProvider)();
    final all = ref.watch(categoriesProvider()).value ?? const <Category>[];
    final category = all.where((c) => c.id == categoryId).firstOrNull;
    final history =
        ref.watch(transactionsProvider(categoryId: categoryId)).value ??
        const <Transaction>[];

    Widget scaffold(Widget body) => Scaffold(
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
          l10n.categoryTitle,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: body,
    );
    if (category == null) return scaffold(const SizedBox.shrink());

    final period = periodFor(today, prefs.monthStartDay);
    final spent = history
        .where((t) => period.contains(t.occurredAt))
        .fold(0, (sum, t) => sum + t.amountMinor);
    final isExpense = category.type == TransactionType.expense;
    final limit = category.limitMinor;
    final repository = ref.read(categoryRepositoryProvider);

    Future<void> editLimit() async {
      final result = await showAmountSheet(
        context,
        title: l10n.monthlyLimit,
        leading: CategoryTile.forKey(
          category.iconKey,
          color: category.colorKey,
        ),
        currency: currency,
        initialMinor: limit ?? 0,
        removable: limit != null,
        maxMinor: maxLimitFor(
          category.id,
          categories: all.where(
            (c) => c.type == TransactionType.expense && !c.archived,
          ),
          budgetMinor: prefs.monthlyBudgetMinor,
        ),
      );
      if (result == null) return;
      await repository.update(
        category.copyWith(
          limitMinor: switch (result) {
            AmountSaved(:final minor) => minor,
            AmountRemoved() => null,
          },
        ),
      );
    }

    return scaffold(
      ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          8,
          AppSpacing.screenX,
          32,
        ),
        children: [
          CategoryPeriodCard(
            category: category,
            typeAndCount: l10n.categoryTypeCount(
              isExpense ? l10n.expenseLabel : l10n.incomeLabel,
              history.length,
            ),
            spentMinor: spent,
            daysLeft: daysLeft(period, today),
            currency: currency,
          ),
          const SizedBox(height: 28),
          SectionLabel(l10n.settings),
          ListGroup(
            children: [
              ListGroupRow(
                title: l10n.nameLabel,
                value: category.name,
                onTap: () => showCategoryNameSheet(context, category),
              ),
              ListGroupRow(
                title: l10n.iconAndColour,
                trailing: CategoryTile.forKey(
                  category.iconKey,
                  color: category.colorKey,
                  size: CategoryTileSize.small,
                ),
                onTap: () => showCategoryStyleSheet(context, category),
              ),
              if (isExpense)
                ListGroupRow(
                  title: l10n.monthlyLimit,
                  value: limit == null
                      ? l10n.noLimit
                      : formatter.formatCompact(limit),
                  onTap: editLimit,
                ),
            ],
          ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionLabel(l10n.recentSection),
            ListGroup(
              children: [
                for (final t in history.take(_recentCount))
                  TransactionRow(
                    compact: true,
                    title: t.title,
                    caption: l10n.dayHeaderLabel(
                      t.occurredAt.toLocal(),
                      today,
                      locale,
                    ),
                    amountMinor: t.amountMinor,
                    type: t.type,
                    currency: currency,
                    onTap: () =>
                        unawaited(context.push(Routes.transaction(t.id))),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => category.archived
                  ? repository.restore(category.id)
                  : repository.archive(category.id),
              style: TextButton.styleFrom(
                foregroundColor: category.archived
                    ? colors.ink
                    : colors.negative,
                minimumSize: const Size(44, 44),
              ),
              child: Text(
                category.archived ? l10n.restoreCategory : l10n.archiveCategory,
                style: text.rowTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
