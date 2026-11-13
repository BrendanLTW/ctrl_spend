import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S12/S13's amount: "TOTAL AMOUNT", the symbol and large digits with
/// full-size cents, green for income. Tapping it opens the keypad.
class TransactionAmountCard extends StatelessWidget {
  const new({
    required this.minor,
    required this.currency,
    required this.income,
    required this.onTap,
    super.key,
  });

  final int minor;
  final Currency currency;
  final bool income;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(currency);
    final (:head, :cents) = formatter.split(minor);
    final digits = head.substring(currency.symbol.length + 1) + cents;
    final colour = income ? colors.positive : colors.ink;
    return Semantics(
      button: true,
      liveRegion: true,
      label: l10n.totalAmountLabel(formatter.format(minor)),
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r32),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Column(
              children: [
                Text(
                  l10n.totalAmount.toUpperCase(),
                  style: text.label.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        currency.symbol,
                        style: text.pageTitle.copyWith(color: colors.ink),
                      ),
                      const SizedBox(width: 16),
                      Text(digits, style: text.display.copyWith(color: colour)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the sheet keypad over the form, reporting each change through
/// [onChanged] so the amount card updates as keys are pressed.
Future<void> showKeypadSheet(
  BuildContext context, {
  required int initialMinor,
  required ValueChanged<int> onChanged,
}) => showAppSheet<void>(
  context,
  title: context.l10n.amountSheetTitle,
  builder: (_) =>
      _KeypadSheetBody(initialMinor: initialMinor, onChanged: onChanged),
);

class _KeypadSheetBody extends StatefulWidget {
  const new({required this.initialMinor, required this.onChanged});

  final int initialMinor;
  final ValueChanged<int> onChanged;

  @override
  State<_KeypadSheetBody> createState() => _KeypadSheetBodyState();
}

class _KeypadSheetBodyState extends State<_KeypadSheetBody> {
  late int _minor = widget.initialMinor;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      MoneyKeypad(
        value: _minor,
        size: MoneyKeypadSize.sheet,
        onChanged: (minor) {
          setState(() => _minor = minor);
          widget.onChanged(minor);
        },
      ),
      const SizedBox(height: 16),
      PrimaryButton(
        label: context.l10n.done,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
