import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_display.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// What the amount sheet ended with; null means it was dismissed.
sealed class AmountSheetResult {
  const new();
}

final class AmountSaved extends AmountSheetResult {
  const new(this.minor);

  final int minor;
}

final class AmountRemoved extends AmountSheetResult {
  const new();
}

/// The keypad sheet for a per-month amount (S06, S17): [leading] tile and
/// [title], the amount, the sheet keypad and Save. [removable] puts
/// "Remove" in the header instead of ✕. With [maxMinor], amounts above it
/// can't be saved and the room left is shown. Save needs more than 0.
Future<AmountSheetResult?> showAmountSheet(
  BuildContext context, {
  required String title,
  required Currency currency,
  required int initialMinor,
  Widget? leading,
  bool removable = false,
  int? maxMinor,
}) {
  final l10n = context.l10n;
  return showAppSheet<AmountSheetResult>(
    context,
    title: title,
    leading: leading,
    trailing: removable
        ? Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).pop(const AmountRemoved()),
              style: TextButton.styleFrom(
                minimumSize: const Size(52, 48),
                foregroundColor: context.colors.negative,
              ),
              child: Text(
                l10n.remove,
                style: context.text.rowTitle.copyWith(
                  color: context.colors.negative,
                ),
              ),
            ),
          )
        : null,
    builder: (_) => _AmountSheetBody(
      currency: currency,
      initialMinor: initialMinor,
      maxMinor: maxMinor,
    ),
  );
}

class _AmountSheetBody extends StatefulWidget {
  const new({
    required this.currency,
    required this.initialMinor,
    required this.maxMinor,
  });

  final Currency currency;
  final int initialMinor;
  final int? maxMinor;

  @override
  State<_AmountSheetBody> createState() => _AmountSheetBodyState();
}

class _AmountSheetBodyState extends State<_AmountSheetBody> {
  late int _minor = widget.initialMinor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(widget.currency);
    final max = widget.maxMinor;
    final over = max != null && _minor > max;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: colors.fillSoft,
            borderRadius: BorderRadius.circular(AppRadius.r28),
          ),
          child: Column(
            children: [
              AmountDisplay(
                minor: _minor,
                currency: widget.currency,
                size: MoneyKeypadSize.sheet,
                label: l10n.perMonth.toUpperCase(),
                semanticLabel: l10n.budgetPerMonthLabel(
                  formatter.format(_minor),
                ),
              ),
              if (max != null)
                Text(
                  l10n.leftToAllocate(formatter.formatCompact(max)),
                  textAlign: TextAlign.center,
                  style: text.caption.copyWith(
                    color: over ? colors.negative : colors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MoneyKeypad(
          value: _minor,
          size: MoneyKeypadSize.sheet,
          onChanged: (minor) => setState(() => _minor = minor),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.save,
          onPressed: _minor > 0 && !over
              ? () => Navigator.of(context).pop(AmountSaved(_minor))
              : null,
        ),
      ],
    );
  }
}
