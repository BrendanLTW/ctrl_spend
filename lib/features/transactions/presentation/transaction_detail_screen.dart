import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/features/transactions/presentation/budget_impact_card.dart';
import 'package:ctrl_spend/features/transactions/presentation/delete_transaction.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S41 Transaction: the entry, its details and its effect on the budget
/// of the period it falls in. Follows edits live; closes if it's deleted.
class TransactionDetailScreen extends ConsumerStatefulWidget {
  const new({required this.transactionId, super.key});

  final int transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  var _closing = false;

  /// Leaves once, e.g. after it was deleted from S13 on top of this.
  void _close() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final all = ref.watch(transactionsProvider()).value;
    final transaction = all
        ?.where((t) => t.id == widget.transactionId)
        .firstOrNull;
    if (all != null && transaction == null) _close();
    final categories = {
      for (final c
          in ref.watch(categoriesProvider()).value ?? const <Category>[])
        c.id: c,
    };
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final category = transaction == null
        ? null
        : categories[transaction.categoryId];

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.transactionTitle,
          style: context.text.header.copyWith(color: colors.ink),
        ),
      ),
      body: transaction == null || category == null
          ? const SizedBox()
          : SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenX,
                        8,
                        AppSpacing.screenX,
                        16,
                      ),
                      children: [
                        _Summary(
                          transaction: transaction,
                          category: category,
                          currency: currency,
                        ),
                        const SizedBox(height: 24),
                        SectionLabel(l10n.details),
                        _Details(transaction: transaction, category: category),
                        ..._impact(
                          context,
                          transaction: transaction,
                          category: category,
                          all: all!,
                          prefs: prefs,
                          currency: currency,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenX,
                      0,
                      AppSpacing.screenX,
                      8,
                    ),
                    child: Column(
                      children: [
                        PrimaryButton(
                          label: l10n.editAction,
                          onPressed: () => context.push(
                            Routes.editTransaction(transaction.id),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () async {
                            final deleted = await confirmAndDeleteTransaction(
                              context,
                              ref,
                              transaction: transaction,
                              category: category,
                              currency: currency,
                            );
                            if (deleted) _close();
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(52, 52),
                            foregroundColor: colors.negative,
                          ),
                          child: Text(
                            l10n.deleteTransaction,
                            style: context.text.rowTitle.copyWith(
                              color: colors.negative,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// The Budget impact section: the category's limit, else the monthly
  /// budget; nothing for income or when there's nothing to measure.
  List<Widget> _impact(
    BuildContext context, {
    required Transaction transaction,
    required Category category,
    required List<Transaction> all,
    required Preferences prefs,
    required Currency currency,
  }) {
    if (transaction.type == TransactionType.income) return const [];
    final l10n = context.l10n;
    final period = periodFor(transaction.occurredAt, prefs.monthStartDay);
    final (name, spent, limit) = switch (category.limitMinor) {
      final limit? => (
        category.name,
        spentByCategory(all, period)[category.id] ?? 0,
        limit,
      ),
      null => (
        l10n.monthlyBudget,
        periodTotals(all, period).spentMinor,
        prefs.monthlyBudgetMinor,
      ),
    };
    if (limit == null) return const [];
    final formatter = MoneyFormatter(currency);
    final current = periodFor(ref.watch(clockProvider)(), prefs.monthStartDay);
    final spentText = formatter.formatCompact(spent);
    final limitText = formatter.formatCompact(limit);
    return [
      const SizedBox(height: 24),
      SectionLabel(l10n.budgetImpact),
      BudgetImpactCard(
        name: name,
        spentMinor: spent,
        limitMinor: limit,
        currency: currency,
        caption: period == current
            ? l10n.spentOfThisPeriod(spentText, limitText)
            : l10n.spentOfInPeriod(
                spentText,
                limitText,
                formatPeriod(
                  period,
                  Localizations.localeOf(context).toLanguageTag(),
                ),
              ),
      ),
    ];
  }
}

/// The tile, title, signed amount and type chip.
class _Summary extends StatelessWidget {
  const new({
    required this.transaction,
    required this.category,
    required this.currency,
  });

  final Transaction transaction;
  final Category category;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final expense = transaction.type == TransactionType.expense;
    final tile = context.categoryColors.of(category.colorKey);
    return Column(
      children: [
        ExcludeSemantics(
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: tile.tile,
              borderRadius: BorderRadius.circular(AppRadius.r20),
            ),
            child: Icon(
              categoryIcon(category.iconKey),
              size: 30,
              color: tile.icon,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Semantics(
          header: true,
          child: Text(
            transaction.title,
            textAlign: TextAlign.center,
            style: text.header.copyWith(color: colors.ink),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            MoneyFormatter(currency).format(
              transaction.amountMinor,
              sign: expense ? MoneySign.expense : MoneySign.income,
            ),
            style: text.welcomeTitle.copyWith(
              color: expense ? colors.negative : colors.positive,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: ShapeDecoration(
            color: colors.raised,
            shape: const StadiumBorder(),
          ),
          child: Text(
            expense ? l10n.expenseLabel : l10n.incomeLabel,
            style: text.caption.copyWith(
              color: colors.chipText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Category, Date with time, and Note when there is one.
class _Details extends StatelessWidget {
  const new({required this.transaction, required this.category});

  final Transaction transaction;
  final Category category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final at = transaction.occurredAt.toLocal();
    final note = transaction.note;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.r28),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _DetailRow(
            label: l10n.categoryRowLabel,
            value: category.name,
            leading: CategoryTile.forKey(
              category.iconKey,
              color: category.colorKey,
              size: CategoryTileSize.small,
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.divider),
          _DetailRow(
            label: l10n.dateRowLabelTitle,
            value: l10n.dateAndTime(
              DateFormat('EEE, d MMM', locale).format(at),
              DateFormat.jm(locale).format(at),
            ),
          ),
          if (note != null && note.isNotEmpty) ...[
            Divider(height: 1, thickness: 1, color: colors.divider),
            _DetailRow(label: l10n.noteRowLabel, value: note),
          ],
        ],
      ),
    );
  }
}

/// S41's detail row: the label in `ink`, the value muted on the right.
class _DetailRow extends StatelessWidget {
  const new({required this.label, required this.value, this.leading});

  final String label;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      label: '$label, $value',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Text(label, style: text.rowTitle.copyWith(color: colors.ink)),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (leading case final leading?) ...[
                      leading,
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        style: text.rowTitleSm.copyWith(color: colors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
