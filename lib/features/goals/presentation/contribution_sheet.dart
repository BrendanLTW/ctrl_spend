import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_display.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_text_field.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// What Add money or Withdraw saved: the amount and the note, if any.
typedef Contribution = ({int amountMinor, String note});

/// The longest contribution note (S30's "From salary").
const maxContributionNote = 40;

/// S30's Add money and Withdraw: the amount on the sheet keypad and an
/// optional note. With [maxMinor] (Withdraw), more than that can't be
/// saved and what's saved is shown. Resolves to null if dismissed.
Future<Contribution?> showContributionSheet(
  BuildContext context, {
  required String title,
  required Currency currency,
  int? maxMinor,
}) => showAppSheet<Contribution>(
  context,
  title: title,
  builder: (sheet) => ConstrainedBox(
    // The sheet doesn't scroll; this does, so large text still fits.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(sheet).height * 0.8,
    ),
    child: SingleChildScrollView(
      child: _ContributionBody(currency: currency, maxMinor: maxMinor),
    ),
  ),
);

class _ContributionBody extends StatefulWidget {
  const new({required this.currency, required this.maxMinor});

  final Currency currency;
  final int? maxMinor;

  @override
  State<_ContributionBody> createState() => _ContributionBodyState();
}

class _ContributionBodyState extends State<_ContributionBody> {
  int _minor = 0;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

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
                semanticLabel: l10n.contributionAmountLabel(
                  formatter.format(_minor),
                ),
              ),
              if (max != null)
                Text(
                  l10n.withdrawAtMost(formatter.formatCompact(max)),
                  textAlign: TextAlign.center,
                  style: text.caption.copyWith(
                    color: over ? colors.negative : colors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _note,
          hint: l10n.addNote,
          icon: AppIcon.note,
          maxLength: maxContributionNote,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 12),
        MoneyKeypad(
          value: _minor,
          size: MoneyKeypadSize.sheet,
          onChanged: (minor) => setState(() => _minor = minor),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.save,
          onPressed: _minor > 0 && !over
              ? () =>
                    Navigator.of(context)
                        .pop((amountMinor: _minor, note: _note.text.trim()))
              : null,
        ),
      ],
    );
  }
}
