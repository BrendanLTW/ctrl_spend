import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_display.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/message_box.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S54's message for an amount over the most allowed: the text, and the
/// part of it to show in bold ("RM 1,500").
typedef OverMessage = ({String text, String bold}) Function(int minor);

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
/// can't be saved and [overMessage] says why; with [minMinor], amounts
/// below it can't be saved and [minMessage] says why. Either shows as
/// S54: a red outline on the amount and an error message box. Save needs
/// more than 0.
Future<AmountSheetResult?> showAmountSheet(
  BuildContext context, {
  required String title,
  required Currency currency,
  required int initialMinor,
  Widget? leading,
  bool removable = false,
  int? maxMinor,
  OverMessage? overMessage,
  int? minMinor,
  String? minMessage,
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
      overMessage: overMessage,
      minMinor: minMinor,
      minMessage: minMessage,
    ),
  );
}

class _AmountSheetBody extends StatefulWidget {
  const new({
    required this.currency,
    required this.initialMinor,
    required this.maxMinor,
    required this.overMessage,
    required this.minMinor,
    required this.minMessage,
  });

  final Currency currency;
  final int initialMinor;
  final int? maxMinor;
  final OverMessage? overMessage;
  final int? minMinor;
  final String? minMessage;

  @override
  State<_AmountSheetBody> createState() => _AmountSheetBodyState();
}

class _AmountSheetBodyState extends State<_AmountSheetBody> {
  late int _minor = widget.initialMinor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(widget.currency);
    final max = widget.maxMinor;
    final over = max != null && _minor > max;
    final min = widget.minMinor;
    final under = min != null && _minor < min;
    final message = over
        ? widget.overMessage?.call(_minor)
        : under && widget.minMessage != null
        ? (text: widget.minMessage!, bold: '')
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: colors.ground,
            borderRadius: BorderRadius.circular(AppRadius.r24),
            border: Border.all(
              color: over || under ? colors.negative : Colors.transparent,
              width: 2,
            ),
          ),
          child: AmountDisplay(
            minor: _minor,
            currency: widget.currency,
            size: MoneyKeypadSize.sheet,
            label: l10n.perMonth.toUpperCase(),
            semanticLabel: l10n.budgetPerMonthLabel(formatter.format(_minor)),
          ),
        ),
        if (message case (:final text, :final bold)) ...[
          const SizedBox(height: 12),
          MessageBox(
            text,
            kind: MessageKind.error,
            child: _boldPart(text, bold),
          ),
        ],
        const SizedBox(height: 16),
        MoneyKeypad(
          value: _minor,
          size: MoneyKeypadSize.sheet,
          onChanged: (minor) => setState(() => _minor = minor),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.save,
          onPressed: _minor > 0 && !over && !under
              ? () => Navigator.of(context).pop(AmountSaved(_minor))
              : null,
        ),
      ],
    );
  }
}

/// [text] with its last [bold] in 600, as S54 shows the most allowed.
Widget _boldPart(String text, String bold) {
  final at = bold.isEmpty ? -1 : text.lastIndexOf(bold);
  if (at < 0) return Text(text);
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(text: text.substring(0, at)),
        TextSpan(
          text: bold,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(text: text.substring(at + bold.length)),
      ],
    ),
  );
}
