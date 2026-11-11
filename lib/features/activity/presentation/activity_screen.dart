import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/swipe_to_delete.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/activity/domain/day_groups.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/date_labels.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S16 Activity: every transaction by day, newest first, with each day's
/// net. Swipe a row left to delete it, with a 5-second Undo.
// shortcut: search and filter chips (S16, S39) come in task 3.1.
class ActivityScreen extends ConsumerWidget {
  const new({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    final l10n = context.l10n;
    final repository = ref.read(transactionRepositoryProvider);
    final deleted = await repository.delete(transaction.id);
    if (!context.mounted) return;
    showAppToast(
      context,
      message: l10n.transactionDeleted,
      actionLabel: l10n.undo,
      onAction: () => repository.restore(deleted),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = ref.watch(clockProvider)();
    final currency = Currency.fromCode(
      ref.watch(preferencesProvider).value?.currencyCode ?? '',
    );
    final transactions = ref.watch(transactionsProvider()).value;
    final categories = <int, Category>{
      for (final c
          in ref.watch(categoriesProvider()).value ?? const <Category>[])
        c.id: c,
    };
    final formatter = MoneyFormatter(currency);

    // Headers and rows in one flat list, so it builds lazily.
    final items = <Widget Function()>[];
    for (final group in groupByDay(transactions ?? const [])) {
      items.add(
        () => _DayHeader(
          label: l10n.dayHeaderLabel(group.day, today, locale),
          // "+RM 4,800.00" for a day that brought money in (S16).
          net: formatter.format(
            group.netMinor,
            sign: group.netMinor > 0 ? MoneySign.income : MoneySign.auto,
          ),
        ),
      );
      for (final t in group.transactions) {
        final category = categories[t.categoryId];
        if (category == null) continue;
        items.add(
          () => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: SwipeToDelete(
              key: ValueKey(t.id),
              deleteLabel: l10n.delete,
              radius: 22,
              onDelete: () => _delete(context, ref, t),
              child: TransactionRow(
                compact: true,
                tile: CategoryTile.forKey(
                  category.iconKey,
                  color: category.colorKey,
                  size: CategoryTileSize.compact,
                ),
                title: t.title,
                caption: t.type == TransactionType.income
                    ? l10n.incomeLabel
                    : category.name,
                amountMinor: t.amountMinor,
                type: t.type,
                currency: currency,
                onTap: () => context.push(Routes.transaction(t.id)),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.textX,
                16,
                AppSpacing.textX,
                8,
              ),
              sliver: SliverToBoxAdapter(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.tabActivity,
                    style: text.welcomeTitle.copyWith(color: colors.ink),
                  ),
                ),
              ),
            ),
            if (transactions != null && transactions.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenX),
                sliver: SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.noTransactionsTitle,
                    body: l10n.noTransactionsBody,
                    actionLabel: l10n.addFirstExpense,
                    onAction: () => context.push(Routes.add),
                  ),
                ),
              )
            else
              SliverPadding(
                // Clear of the floating bottom bar.
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  0,
                  AppSpacing.screenX,
                  120,
                ),
                sliver: SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) => items[i](),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "TODAY" with the day's net on the right.
class _DayHeader extends StatelessWidget {
  const new({required this.label, required this.net});

  final String label;
  final String net;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      header: true,
      label: '$label, $net',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.textX - AppSpacing.screenX,
          16,
          AppSpacing.textX - AppSpacing.screenX,
          12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: text.label.copyWith(color: colors.muted),
              ),
            ),
            Text(net, style: text.rowTitleSm.copyWith(color: colors.muted)),
          ],
        ),
      ),
    );
  }
}
