import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/l10n/date_labels.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S09's Recent activities: a header with View all and the latest
/// transactions, captioned "Today · Food" (income reads "Income").
class RecentActivities extends StatelessWidget {
  const new({
    required this.transactions,
    required this.categories,
    required this.currency,
    required this.today,
    required this.onViewAll,
    required this.onOpen,
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
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.ink,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
