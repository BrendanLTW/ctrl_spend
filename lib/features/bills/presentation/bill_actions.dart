import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/domain/bill_repository.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_labels.dart';
import 'package:ctrl_spend/features/bills/presentation/repeat_picker_sheet.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _BillAction { markPaid, edit, delete }

/// What tapping an upcoming bill on S27 offers: Mark paid, Edit bill and
/// Delete bill. Not on the canvas (see docs/design-notes.md).
Future<void> showBillActions(
  BuildContext context,
  WidgetRef ref, {
  required Bill bill,
}) async {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final currency = Currency.fromCode(
    ref.read(preferencesProvider).value?.currencyCode ?? '',
  );
  final now = ref.read(clockProvider)();
  final today = DateTime(now.year, now.month, now.day);
  final amount = MoneyFormatter(currency).format(bill.amountMinor);
  final due = l10n.dueLabel(bill.nextDue, today, locale);

  final action = await showAppSheet<_BillAction>(
    context,
    title: bill.name,
    leading: CategoryTile.forKey(bill.iconKey, color: bill.colorKey),
    builder: (sheet) {
      final colors = sheet.colors;
      void choose(_BillAction a) => Navigator.of(sheet).pop(a);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$amount · $due',
            style: sheet.text.body.copyWith(color: colors.muted),
          ),
          const SizedBox(height: 16),
          SheetListGroup(
            children: [
              ListGroupRow(
                title: l10n.markPaid,
                onTap: () => choose(_BillAction.markPaid),
              ),
              ListGroupRow(
                title: l10n.editBill,
                onTap: () => choose(_BillAction.edit),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // On the sheet, not the card: red on `fillSoft` is too faint.
          TextLink(
            label: l10n.deleteBill,
            destructive: true,
            onPressed: () => choose(_BillAction.delete),
          ),
        ],
      );
    },
  );
  if (action == null || !context.mounted) return;
  final repository = ref.read(billRepositoryProvider);
  switch (action) {
    case _BillAction.markPaid:
      await repository.markPaid(bill.id, paidAt: ref.read(clockProvider)());
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.billMarkedPaid(bill.name),
          success: true,
        );
      }
    case _BillAction.edit:
      unawaited(context.push(Routes.editBill(bill.id)));
    case _BillAction.delete:
      final confirmed = await showAppDialog(
        context,
        icon: AppIcon.trash,
        title: l10n.deleteBillTitle(bill.name),
        body: l10n.deleteBillBody,
        confirmLabel: l10n.delete,
        destructive: true,
      );
      if (confirmed) await repository.delete(bill.id);
  }
}
