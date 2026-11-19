import 'package:ctrlspend/core/money/money_formatter.dart';
import 'package:ctrlspend/core/period/clock.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/app_sheet.dart';
import 'package:ctrlspend/core/widgets/app_toast.dart';
import 'package:ctrlspend/core/widgets/category_tile.dart';
import 'package:ctrlspend/core/widgets/date_picker_sheet.dart';
import 'package:ctrlspend/core/widgets/message_box.dart';
import 'package:ctrlspend/core/widgets/primary_button.dart';
import 'package:ctrlspend/features/bills/domain/bill.dart';
import 'package:ctrlspend/features/bills/domain/bill_calculations.dart';
import 'package:ctrlspend/features/bills/domain/bill_repository.dart';
import 'package:ctrlspend/features/categories/domain/category.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:ctrlspend/features/transactions/presentation/transaction_amount_card.dart';
import 'package:ctrlspend/l10n/date_labels.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// S57 Mark as paid: the amount (the bill's by default), the day it was
/// paid (today by default) and its category, what paying will do, and
/// Mark as paid. The category is the bill's, as designed.
Future<void> showMarkPaidSheet(
  BuildContext context, {
  required Bill bill,
  required Category category,
}) => showAppSheet<void>(
  context,
  title: context.l10n.markPaid,
  subtitle: bill.name,
  leading: CategoryTile.forKey(category.iconKey, color: category.colorKey),
  trailing: const SizedBox.shrink(),
  builder: (_) => _MarkPaidBody(bill: bill, category: category),
);

class _MarkPaidBody extends ConsumerStatefulWidget {
  const new({required this.bill, required this.category});

  final Bill bill;
  final Category category;

  @override
  ConsumerState<_MarkPaidBody> createState() => _MarkPaidBodyState();
}

class _MarkPaidBodyState extends ConsumerState<_MarkPaidBody> {
  late int _amount = widget.bill.amountMinor;
  late DateTime _paidOn = _today;
  bool _saving = false;

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickDay() async {
    final day = await showDatePickerSheet(
      context,
      title: context.l10n.billPaidOnRow,
      initial: _paidOn,
      today: _today,
      lastDate: _today,
    );
    if (day != null) setState(() => _paidOn = day);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final now = ref.read(clockProvider)();
    // Today keeps the time now; another day is recorded at noon.
    final paidAt = DateUtils.isSameDay(_paidOn, now)
        ? now
        : DateTime(_paidOn.year, _paidOn.month, _paidOn.day, 12);
    await ref
        .read(billRepositoryProvider)
        .markPaid(widget.bill.id, paidAt: paidAt, amountMinor: _amount);
    if (!mounted) return;
    final message = context.l10n.billMarkedPaid(widget.bill.name);
    Navigator.of(context).pop();
    showAppToast(context, message: message, success: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = MoneyFormatter(
      Currency.fromCode(
        ref.watch(preferencesProvider).value?.currencyCode ?? '',
      ),
    );
    final next = nextDue(widget.bill.nextDue, widget.bill.repeat);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colors.ground,
          borderRadius: BorderRadius.circular(AppRadius.r24),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _SheetRow(
                label: l10n.billAmountRow,
                value: formatter.format(_amount),
                onTap: () => showKeypadSheet(
                  context,
                  initialMinor: _amount,
                  onChanged: (minor) => setState(() => _amount = minor),
                ),
              ),
              Divider(height: 1, thickness: 1, color: colors.divider),
              _SheetRow(
                label: l10n.billPaidOnRow,
                value: l10n.dateRowLabel(_paidOn, _today, locale),
                onTap: _pickDay,
              ),
              Divider(height: 1, thickness: 1, color: colors.divider),
              _SheetRow(
                label: l10n.categoryRowLabel,
                value: widget.category.name,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        MessageBox(
          l10n.markPaidNote(
            formatter.format(_amount),
            widget.category.name,
            DateFormat('d MMM', locale).format(next),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.markPaid,
          size: PrimaryButtonSize.sheet,
          onPressed: _amount > 0 && !_saving ? _save : null,
        ),
      ],
    );
  }
}

/// A label and its value; with [onTap] a chevron, as on S57's design.
class _SheetRow extends StatelessWidget {
  const new({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      button: onTap != null,
      label: '$label, $value',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: text.body.copyWith(color: colors.muted),
                  ),
                ),
                Text(value, style: text.rowTitleSm.copyWith(color: colors.ink)),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  AppIconView(
                    AppIcon.chevronRight,
                    size: 18,
                    color: colors.ink,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
