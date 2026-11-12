import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/insights/domain/insight_calculations.dart';
import 'package:ctrl_spend/features/insights/presentation/category_share_card.dart';
import 'package:ctrl_spend/features/insights/presentation/spending_donut.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S18's Month view: this period's spending as a ring and ranked category
/// cards. With no spending yet it shows S40.
class InsightsMonthView extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final formatter = MoneyFormatter(currency);
    final period = periodFor(ref.watch(clockProvider)(), prefs.monthStartDay);
    final inPeriod =
        ref.watch(transactionsProvider(period: period)).value ?? const [];
    // Archived ones too: they keep their history here.
    final categories = <int, Category>{
      for (final c
          in ref.watch(categoriesProvider()).value ?? const <Category>[])
        c.id: c,
    };
    final shares = [
      for (final s in categoryShares(inPeriod, period))
        if (categories[s.categoryId] case final category?) (s, category),
    ];

    if (shares.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 28),
          EmptyState(
            card: false,
            graphic: SpendingDonut(
              segments: const [],
              caption: l10n.spentLabel,
              totalMinor: 0,
              currency: currency,
              semanticLabel: '',
            ),
            title: l10n.insightsEmptyTitle,
            body: l10n.insightsEmptyBody,
            actionLabel: l10n.addAnExpense,
            onAction: () => context.push(Routes.add),
          ),
        ],
      );
    }

    final total = shares.fold(0, (sum, s) => sum + s.$1.spentMinor);
    final shareLabels = [
      for (final (s, category) in shares)
        l10n.categoryShare(
          category.name,
          s.percent,
          formatter.formatCompact(s.spentMinor),
        ),
    ];
    final cards = [
      for (final (i, (s, category)) in shares.indexed)
        CategoryShareCard(
          category: category,
          percent: s.percent,
          amount: formatter.formatCompact(s.spentMinor),
          semanticLabel: shareLabels[i],
        ),
    ];
    final caption = l10n.spentInPeriod(formatPeriod(period, locale));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(
          child: SpendingDonut(
            segments: [
              for (final (s, category) in shares)
                (ChartPalette.of(category.colorKey), s.spentMinor.toDouble()),
            ],
            caption: caption,
            totalMinor: total,
            currency: currency,
            semanticLabel:
                '$caption, ${formatter.format(total)}. '
                '${l10n.spendingSummary(shareLabels.join('; '))}',
          ),
        ),
        const SizedBox(height: 16),
        SectionLabel(l10n.spendingCategories),
        for (var i = 0; i < cards.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.cardGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[i]),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(
                child: i + 1 < cards.length
                    ? cards[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
