import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/pay_pill.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/domain/bill_calculations.dart';
import 'package:ctrl_spend/features/bills/domain/bill_repository.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_labels.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_row.dart';
import 'package:ctrl_spend/features/bills/presentation/mark_paid_sheet.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S27 Recurring bills: what's due before the period ends and what that
/// leaves to spend, the upcoming bills (overdue first, S58) with a Pay
/// pill (S57), the ones paid this period, and paused ones last. A row
/// opens S56. With none it's S59. Unpaid bills never change "Left to
/// spend" elsewhere (PRD §5.11).
class RecurringBillsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final currency = Currency.fromCode(prefs.currencyCode);
    final formatter = MoneyFormatter(currency);
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final period = periodFor(now, prefs.monthStartDay);
    final bills = ref.watch(billsProvider).value;
    final inPeriod =
        ref.watch(transactionsProvider(period: period)).value ??
        const <Transaction>[];
    final categories = {
      for (final c
          in ref.watch(categoriesProvider()).value ?? const <Category>[])
        c.id: c,
    };
    // Every bill shows its category's tile (PRD §5.11).
    Widget tileFor(int categoryId) => switch (categories[categoryId]) {
      final c? => CategoryTile.forKey(
        c.iconKey,
        color: c.colorKey,
        size: CategoryTileSize.compact,
      ),
      null => const SizedBox(width: 44, height: 44),
    };
    void openBill(Bill bill) => unawaited(context.push(Routes.bill(bill.id)));

    void addBill() => unawaited(context.push(Routes.newBill));

    final Widget body;
    if (bills == null) {
      body = const SizedBox.shrink();
    } else if (bills.isEmpty) {
      // S59.
      body = ListView(
        padding: const EdgeInsets.only(top: 170, bottom: 32),
        children: [
          EmptyState(
            card: false,
            icon: AppIcon.repeat,
            title: l10n.noBillsTitle,
            body: l10n.noBillsBody,
            actionLabel: l10n.addBill,
            onAction: addBill,
          ),
        ],
      );
    } else {
      final due = paymentsDue(bills, period);
      final overdue = due.where((p) => p.due.isBefore(today)).length;
      final active = [
        for (final b in bills)
          if (!b.paused) b,
      ];
      final paused = [
        for (final b in bills)
          if (b.paused) b,
      ];
      final paid = [
        for (final t in inPeriod)
          if (t.billId != null) t,
      ];
      final byId = {for (final b in bills) b.id: b};

      body = ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          8,
          AppSpacing.screenX,
          32,
        ),
        children: [
          _DueCard(
            periodEnd: DateFormat('d MMM', locale).format(period.end),
            dueMinor: due.fold(0, (sum, p) => sum + p.bill.amountMinor),
            count: due.length,
            overdue: overdue,
            leftAfterMinor: leftAfterBills(
              budgetMinor: prefs.monthlyBudgetMinor,
              spentMinor: periodTotals(inPeriod, period).spentMinor,
              due: due,
            ),
            currency: currency,
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionLabel(l10n.billsUpcoming),
            ListGroup(
              children: [
                for (final bill in active)
                  BillRow(
                    tile: tileFor(bill.categoryId),
                    title: bill.name,
                    caption: l10n.dueLabel(bill.nextDue, today, locale),
                    captionColor: switch (dueSoon(bill.nextDue, today)) {
                      DueSoon.overdue => colors.negative,
                      DueSoon.soon => colors.warning,
                      DueSoon.later => colors.muted,
                    },
                    amount: formatter.format(bill.amountMinor),
                    onTap: () => openBill(bill),
                    action: switch (categories[bill.categoryId]) {
                      final category? => PayPill(
                        label: l10n.payBill,
                        semanticLabel: l10n.payBillLabel(bill.name),
                        onPressed: () => showMarkPaidSheet(
                          context,
                          bill: bill,
                          category: category,
                        ),
                      ),
                      null => null,
                    },
                  ),
              ],
            ),
          ],
          if (paid.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionLabel(l10n.billsPaidThisPeriod),
            ListGroup(
              children: [
                for (final t in paid)
                  BillRow(
                    tile: tileFor(t.categoryId),
                    title: t.title,
                    caption: l10n.billPaid(
                      DateFormat(
                        'd MMM',
                        locale,
                      ).format(t.occurredAt.toLocal()),
                    ),
                    captionColor: colors.positive,
                    amount: formatter.format(t.amountMinor),
                    // Its bill, or the payment once the bill is gone.
                    onTap: switch (byId[t.billId]) {
                      final bill? => () => openBill(bill),
                      null => () => unawaited(
                        context.push(Routes.transaction(t.id)),
                      ),
                    },
                  ),
              ],
            ),
          ],
          if (paused.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionLabel(l10n.billsPausedSection),
            ListGroup(
              children: [
                for (final bill in paused)
                  BillRow(
                    tile: Opacity(
                      opacity: 0.5,
                      child: tileFor(bill.categoryId),
                    ),
                    title: bill.name,
                    caption: l10n.billPausedCaption,
                    captionColor: colors.muted,
                    amount: formatter.format(bill.amountMinor),
                    onTap: () => openBill(bill),
                  ),
              ],
            ),
          ],
        ],
      );
    }

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
          l10n.recurringBills,
          style: text.header.copyWith(color: colors.ink),
        ),
        actions: [
          TextButton(
            onPressed: addBill,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              foregroundColor: colors.ink,
              overlayColor: colors.raised,
            ),
            child: Text(
              l10n.add,
              style: text.rowTitle.copyWith(color: colors.ink),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }
}

/// The card at the top: the total due before the period ends, how many
/// payments, and what's left to spend after them.
class _DueCard extends StatelessWidget {
  const new({
    required this.periodEnd,
    required this.dueMinor,
    required this.count,
    required this.overdue,
    required this.leftAfterMinor,
    required this.currency,
  });

  final String periodEnd;
  final int dueMinor;
  final int count;

  /// How many of [count] are overdue (S58).
  final int overdue;
  final int? leftAfterMinor;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(currency);
    final summary = [
      if (overdue > 0)
        l10n.billsOverdueSummary(overdue, count - overdue)
      else
        l10n.billsDueCount(count),
      switch (leftAfterMinor) {
        null => null,
        final left when left >= 0 => l10n.billsLeftAfter(
          formatter.formatCompact(left),
        ),
        final left => l10n.billsOverAfter(formatter.formatCompact(-left)),
      },
    ].nonNulls.join(' ');
    final label = l10n.billsDueBefore(periodEnd);
    return Semantics(
      container: true,
      label: '$label, ${formatter.format(dueMinor)}, $summary',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: text.label.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AmountText(
                dueMinor,
                currency: currency,
                style: text.displaySm.copyWith(color: colors.ink),
              ),
            ),
            const SizedBox(height: 6),
            Text(summary, style: text.body.copyWith(color: colors.muted)),
          ],
        ),
      ),
    );
  }
}
