import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/filter_chips.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/core/widgets/search_field.dart';
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

/// The chip filter: All, a type, or a category.
typedef _Filter = ({TransactionType? type, int? categoryId});

const _Filter _all = (type: null, categoryId: null);

/// S16 Activity: every transaction by day, newest first, with each day's
/// net, narrowed by search and one chip. Swipe a row left to delete it,
/// with a 5-second Undo. No matches shows S39.
class ActivityScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _search = TextEditingController();
  _Filter _filter = _all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(Transaction transaction) async {
    final l10n = context.l10n;
    final repository = ref.read(transactionRepositoryProvider);
    final deleted = await repository.delete(transaction.id);
    if (!mounted) return;
    showAppToast(
      context,
      message: l10n.transactionDeleted,
      actionLabel: l10n.undo,
      onAction: () => repository.restore(deleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = ref.watch(clockProvider)();
    final currency = Currency.fromCode(
      ref.watch(preferencesProvider).value?.currencyCode ?? '',
    );
    final query = _search.text.trim();
    final any = ref.watch(transactionsProvider()).value;
    final transactions = ref
        .watch(
          transactionsProvider(
            type: _filter.type,
            categoryId: _filter.categoryId,
            search: query.isEmpty ? null : query,
          ),
        )
        .value;
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
              onDelete: () => _delete(t),
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

    // Chips: All, the two types, then active categories, expense first.
    final active =
        [
          for (final c in categories.values)
            if (!c.archived) c,
        ]..sort((a, b) {
          if (a.type != b.type) {
            return a.type == TransactionType.expense ? -1 : 1;
          }
          return a.sortOrder.compareTo(b.sortOrder);
        });
    final chips = <ChipOption<_Filter>>[
      (value: _all, label: l10n.allChip),
      (
        value: (type: TransactionType.expense, categoryId: null),
        label: l10n.expenseLabel,
      ),
      (
        value: (type: TransactionType.income, categoryId: null),
        label: l10n.incomeLabel,
      ),
      for (final c in active)
        (value: (type: null, categoryId: c.id), label: c.name),
    ];
    final chipLabel = chips
        .firstWhere((c) => c.value == _filter, orElse: () => chips.first)
        .label;

    Widget body;
    if (any != null && any.isEmpty) {
      body = SliverPadding(
        padding: const EdgeInsets.all(AppSpacing.screenX),
        sliver: SliverToBoxAdapter(
          child: EmptyState(
            icon: AppIcon.receipt,
            title: l10n.noTransactionsTitle,
            body: l10n.noTransactionsBody,
            actionLabel: l10n.addFirstExpense,
            onAction: () => context.push(Routes.add),
          ),
        ),
      );
    } else if (transactions != null && transactions.isEmpty) {
      final filtered = _filter != _all;
      body = SliverPadding(
        padding: const EdgeInsets.only(top: 48),
        sliver: SliverToBoxAdapter(
          // S39 No results.
          child: EmptyState(
            card: false,
            icon: AppIcon.searchOff,
            title: query.isEmpty
                ? l10n.nothingHereTitle
                : l10n.noResultsTitle(query),
            body: query.isEmpty
                ? l10n.nothingInChip(chipLabel)
                : filtered
                ? l10n.noResultsInChip(chipLabel)
                : l10n.noResultsAll,
            actionLabel: filtered ? l10n.searchAll : null,
            // "Search all" drops the chip and keeps the search text.
            onAction: filtered ? () => setState(() => _filter = _all) : null,
          ),
        ),
      );
    } else {
      body = SliverPadding(
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
      );
    }

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.textX,
                16,
                AppSpacing.textX,
                12,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.tabActivity,
                  style: text.welcomeTitle.copyWith(color: colors.ink),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenX,
              ),
              child: SearchField(
                controller: _search,
                hint: l10n.searchHint,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            FilterChips<_Filter>(
              chips: chips,
              selected: _filter,
              onChanged: (filter) => setState(() => _filter = filter),
            ),
            const SizedBox(height: 4),
            Expanded(child: CustomScrollView(slivers: [body])),
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
        child: SpreadOrStack(
          start: Text(
            label.toUpperCase(),
            style: text.label.copyWith(color: colors.muted),
          ),
          end: Text(net, style: text.rowTitleSm.copyWith(color: colors.muted)),
        ),
      ),
    );
  }
}
