import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/periods/domain/period_summary.dart';
import 'package:ctrl_spend/features/periods/presentation/period_spent_card.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S26 Period detail: the period containing [date], its spent card, and
/// each category's spend and result against its limit. Archived
/// categories keep their history here.
class PeriodDetailScreen extends ConsumerWidget {
  const new({required this.date, super.key});

  /// Any day in the period, usually its start.
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final period = periodFor(date, prefs.monthStartDay);
    final categories =
        ref.watch(categoriesProvider()).value ?? const <Category>[];
    final byId = {for (final c in categories) c.id: c};
    final summary = periodSummary(
      ref.watch(transactionsProvider(period: period)).value ?? const [],
      period: period,
      categories: categories,
      budgetMinor: prefs.monthlyBudgetMinor,
    );

    return Scaffold(
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
          formatPeriod(period, locale),
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          8,
          AppSpacing.screenX,
          32,
        ),
        children: [
          PeriodSpentCard(
            spentMinor: summary.spentMinor,
            leftMinor: summary.leftMinor,
            budgetMinor: prefs.monthlyBudgetMinor,
            currency: currency,
          ),
          if (summary.categories.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionLabel(l10n.byCategory),
            ListGroup(
              children: [
                for (final r in summary.categories)
                  if (byId[r.categoryId] case final category?)
                    _CategoryResultRow(
                      category: category,
                      result: r,
                      formatter: MoneyFormatter(currency),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryResultRow extends StatelessWidget {
  const new({
    required this.category,
    required this.result,
    required this.formatter,
  });

  final Category category;
  final CategoryResult result;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final left = result.leftMinor;
    final limit = category.limitMinor;
    final (status, limitText) = switch ((left, limit)) {
      (final left?, final limit?) => (
        left <= 0
            ? l10n.amountOver(formatter.formatCompact(-left))
            : l10n.amountUnder(formatter.formatCompact(left)),
        l10n.limitAmount(formatter.formatCompact(limit)),
      ),
      _ => (l10n.noLimit, null),
    };
    final over = left != null && left <= 0;
    final subtitleStyle = text.body.copyWith(color: colors.muted);
    final amount = formatter.formatCompact(result.spentMinor);

    return Semantics(
      container: true,
      label: [category.name, status, ?limitText, amount].join(', '),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Row(
          children: [
            CategoryTile.forKey(
              category.iconKey,
              color: category.colorKey,
              size: CategoryTileSize.compact,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SpreadOrStack(
                gap: 10,
                start: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.rowTitle.copyWith(color: colors.ink),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: status,
                            style: over
                                ? subtitleStyle.copyWith(color: colors.negative)
                                : null,
                          ),
                          if (limitText != null)
                            TextSpan(text: ' · $limitText'),
                        ],
                      ),
                      style: subtitleStyle,
                    ),
                  ],
                ),
                end: Text(
                  amount,
                  style: text.rowTitleSm.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
