import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/l10n/date_labels.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S09's Recent activities: a header with View all and the latest
/// transactions, captioned "Today · Food" (income reads "Income"). With
/// none at all it shows the S10 first-run empty state.
class RecentActivities extends StatelessWidget {
  const new({
    required this.transactions,
    required this.categories,
    required this.currency,
    required this.today,
    required this.onViewAll,
    required this.onOpen,
    required this.onAddFirst,
    super.key,
  });

  /// Newest first; the caller limits how many.
  final List<Transaction> transactions;

  /// By id, including archived ones so old entries keep their look.
  final Map<int, Category> categories;
  final Currency currency;
  final DateTime today;
  final VoidCallback onViewAll;
  final ValueChanged<Transaction> onOpen;

  /// The S10 empty state's action, shown when there are no transactions.
  final VoidCallback onAddFirst;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(width: AppSpacing.textX - AppSpacing.screenX),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.recentActivities.toUpperCase(),
                  style: text.label.copyWith(color: colors.muted),
                ),
              ),
            ),
            // Hidden on first run (S10); keeps the header's height.
            if (transactions.isEmpty)
              const SizedBox(height: 44)
            else
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  foregroundColor: colors.ink,
                  overlayColor: colors.raised,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.viewAll,
                      style: text.rowTitle.copyWith(color: colors.ink),
                    ),
                    const SizedBox(width: 4),
                    AppIconView(
                      AppIcon.chevronRight,
                      stroke: AppIconStroke.chevron,
                      size: 20,
                      color: colors.ink,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          EmptyState(
            icon: AppIcon.receipt,
            title: l10n.noTransactionsTitle,
            body: l10n.noTransactionsBody,
            actionLabel: l10n.addFirstExpense,
            onAction: onAddFirst,
          ),
        for (final t in transactions) ...[
          if (categories[t.categoryId] case final category?)
            TransactionRow(
              tile: CategoryTile.forKey(
                category.iconKey,
                color: category.colorKey,
              ),
              title: t.title,
              caption: l10n.dayAndDetail(
                l10n.dayLabel(t.occurredAt, today, locale),
                t.type == TransactionType.income
                    ? l10n.incomeLabel
                    : category.name,
              ),
              amountMinor: t.amountMinor,
              type: t.type,
              currency: currency,
              onTap: () => onOpen(t),
            ),
          const SizedBox(height: AppSpacing.cardGap),
        ],
      ],
    );
  }
}
