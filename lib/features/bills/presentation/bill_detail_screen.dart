import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/domain/bill_repository.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_labels.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_row.dart';
import 'package:ctrl_spend/features/bills/presentation/mark_paid_sheet.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S56 Bill detail: the bill, its repeat and due status; its category,
/// reminder and Pause this bill; the payments it made; then Mark as paid,
/// Edit (S28) and Delete bill. Deleting keeps those payments.
class BillDetailScreen extends ConsumerWidget {
  const new({required this.billId, super.key});

  final int billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency = Currency.fromCode(
      ref.watch(preferencesProvider).value?.currencyCode ?? '',
    );
    final formatter = MoneyFormatter(currency);
    final bill = ref
        .watch(billsProvider)
        .value
        ?.where((b) => b.id == billId)
        .firstOrNull;
    final categories =
        ref.watch(categoriesProvider()).value ?? const <Category>[];
    final category = categories
        .where((c) => c.id == bill?.categoryId)
        .firstOrNull;
    final names = {for (final c in categories) c.id: c.name};
    final history = [
      for (final t
          in ref.watch(transactionsProvider()).value ?? const <Transaction>[])
        if (t.billId == billId) t,
    ];
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);

    Future<void> delete(Bill bill) async {
      final confirmed = await showAppDialog(
        context,
        icon: AppIcon.trash,
        title: l10n.deleteBillTitle(bill.name),
        body: l10n.deleteBillBody,
        confirmLabel: l10n.delete,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
      context.pop();
      await ref.read(billRepositoryProvider).delete(bill.id);
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
          l10n.billTitle,
          style: text.header.copyWith(color: colors.ink),
        ),
        actions: [
          if (bill != null)
            TextButton(
              onPressed: () =>
                  unawaited(context.push(Routes.editBill(bill.id))),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                foregroundColor: colors.ink,
                overlayColor: colors.raised,
              ),
              child: Text(
                l10n.editAction,
                style: text.rowTitle.copyWith(color: colors.ink),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: bill == null || category == null
          ? const SizedBox.shrink()
          : SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenX,
                        4,
                        AppSpacing.screenX,
                        24,
                      ),
                      children: [
                        _BillHero(
                          bill: bill,
                          category: category,
                          currency: currency,
                          repeat: l10n.repeatRuleLabel(bill.repeat),
                          status: bill.paused
                              ? l10n.billPausedCaption
                              : l10n.dueLabel(bill.nextDue, today, locale),
                          statusColor: bill.paused
                              ? AppColors.dark.muted
                              : switch (dueSoon(bill.nextDue, today)) {
                                  DueSoon.overdue => AppColors.dark.negative,
                                  DueSoon.soon => AppColors.dark.warning,
                                  DueSoon.later => AppColors.dark.muted,
                                },
                        ),
                        const SizedBox(height: 12),
                        ListGroup(
                          children: [
                            KeyValueRow(
                              label: l10n.categoryRowLabel,
                              value: category.name,
                            ),
                            KeyValueRow(
                              label: l10n.billReminderRow,
                              value: switch (bill.remindDaysBefore) {
                                final days? => l10n.billReminderDays(days),
                                null => l10n.offLabel,
                              },
                            ),
                            _PauseRow(
                              value: bill.paused,
                              onChanged: (on) => ref
                                  .read(billRepositoryProvider)
                                  .update(bill.copyWith(paused: on)),
                            ),
                          ],
                        ),
                        if (history.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sectionTop),
                          SectionLabel(l10n.billHistory),
                          ListGroup(
                            children: [
                              for (final t in history)
                                BillRow(
                                  title: l10n.billPaid(
                                    DateFormat(
                                      'd MMM',
                                      locale,
                                    ).format(t.occurredAt.toLocal()),
                                  ),
                                  caption: l10n.billHistoryCaption(
                                    names[t.categoryId] ?? '',
                                  ),
                                  captionColor: colors.muted,
                                  amount: formatter.format(t.amountMinor),
                                  onTap: () => unawaited(
                                    context.push(Routes.transaction(t.id)),
                                  ),
                                ),
                            ],
                          ),
                        ],
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButton(
                          label: l10n.markPaid,
                          onPressed: () => showMarkPaidSheet(
                            context,
                            bill: bill,
                            category: category,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextLink(
                            label: l10n.deleteBill,
                            destructive: true,
                            onPressed: () => delete(bill),
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
}

/// The dark card: category icon, name, repeat, amount and due status.
class _BillHero extends StatelessWidget {
  const new({
    required this.bill,
    required this.category,
    required this.currency,
    required this.repeat,
    required this.status,
    required this.statusColor,
  });

  final Bill bill;
  final Category category;
  final Currency currency;
  final String repeat;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    // White on the hero in both themes, as on S26.
    const onHero = AppColors.dark;
    return Semantics(
      container: true,
      label: [
        bill.name,
        repeat,
        MoneyFormatter(currency).format(bill.amountMinor),
        status,
      ].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.colors.hero,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: onHero.ink.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: AppIconView(
                    categoryIcon(category.iconKey),
                    size: 24,
                    color: onHero.ink,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.name,
                        style: text.button.copyWith(color: onHero.ink),
                      ),
                      Text(
                        repeat,
                        style: text.navLabel.copyWith(
                          color: onHero.chipText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AmountText(
                bill.amountMinor,
                currency: currency,
                style: text.amount.copyWith(color: onHero.ink),
                centsColor: onHero.muted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: text.navLabel.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Pause this bill" and its toggle, read as one switch.
class _PauseRow extends StatelessWidget {
  const new({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = context.l10n.pauseBill;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      style: context.text.body.copyWith(color: colors.muted),
                    ),
                  ),
                ),
                AppToggle(
                  value: value,
                  onChanged: onChanged,
                  semanticLabel: label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
