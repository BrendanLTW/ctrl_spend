import 'package:ctrlspend/core/money/money_formatter.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:ctrlspend/core/widgets/amount_display.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/app_sheet.dart';
import 'package:ctrlspend/core/widgets/date_picker_sheet.dart';
import 'package:ctrlspend/core/widgets/large_text.dart';
import 'package:ctrlspend/core/widgets/message_box.dart';
import 'package:ctrlspend/core/widgets/money_keypad.dart';
import 'package:ctrlspend/core/widgets/primary_button.dart';
import 'package:ctrlspend/core/widgets/segmented_control.dart';
import 'package:ctrlspend/features/transactions/presentation/entry_fields.dart';
import 'package:ctrlspend/l10n/date_labels.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// What S60 or S61 saved: which way, the amount, the label and the day.
typedef Contribution = ({
  bool withdraw,
  int amountMinor,
  String label,
  DateTime date,
});

/// The longest contribution label (S30's "From salary").
const maxContributionNote = 40;

/// S60 Add money and S61 Withdraw, one sheet with a toggle between them:
/// the amount on the keypad, a label ("From salary" when adding) and a
/// day (today, or earlier). Adding notes that savings aren't spending; a
/// withdrawal over [savedMinor] is refused with a message. Resolves to
/// null if dismissed.
Future<Contribution?> showContributionSheet(
  BuildContext context, {
  required String goalName,
  required Currency currency,
  required int savedMinor,
  required DateTime today,
  bool withdraw = false,
}) => showAppSheet<Contribution>(
  context,
  title: goalName,
  builder: (sheet) => ConstrainedBox(
    // The sheet doesn't scroll; this does, so large text still fits.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(sheet).height * 0.85,
    ),
    child: SingleChildScrollView(
      child: _ContributionBody(
        currency: currency,
        savedMinor: savedMinor,
        today: today,
        withdraw: withdraw,
      ),
    ),
  ),
);

class _ContributionBody extends StatefulWidget {
  const new({
    required this.currency,
    required this.savedMinor,
    required this.today,
    required this.withdraw,
  });

  final Currency currency;
  final int savedMinor;
  final DateTime today;
  final bool withdraw;

  @override
  State<_ContributionBody> createState() => _ContributionBodyState();
}

class _ContributionBodyState extends State<_ContributionBody> {
  late bool _withdraw = widget.withdraw;
  late DateTime _date = widget.today;
  int _minor = 0;
  final _label = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_withdraw && _label.text.isEmpty) {
      _label.text = context.l10n.contributionDefaultLabel;
    }
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _switch(bool withdraw) => setState(() {
    _withdraw = withdraw;
    // The default label only fits adding; a typed one is kept.
    final defaultLabel = context.l10n.contributionDefaultLabel;
    if (withdraw && _label.text == defaultLabel) _label.clear();
    if (!withdraw && _label.text.isEmpty) _label.text = defaultLabel;
  });

  Future<void> _pickDate() async {
    final day = await showDatePickerSheet(
      context,
      title: context.l10n.dateRowLabelTitle,
      initial: _date,
      today: widget.today,
      lastDate: widget.today,
    );
    if (day != null) setState(() => _date = day);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = MoneyFormatter(widget.currency);
    final over = _withdraw && _minor > widget.savedMinor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedControl<bool>(
          inSheet: true,
          segments: [
            (value: false, label: l10n.addMoney),
            (value: true, label: l10n.withdraw),
          ],
          selected: _withdraw,
          onChanged: _switch,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: colors.ground,
            borderRadius: BorderRadius.circular(AppRadius.r24),
            border: Border.all(
              color: over ? colors.negative : Colors.transparent,
              width: 2,
            ),
          ),
          child: AmountDisplay(
            minor: _minor,
            currency: widget.currency,
            label: l10n.contributionAmount.toUpperCase(),
            size: MoneyKeypadSize.sheet,
            semanticLabel: l10n.contributionAmountLabel(
              formatter.format(_minor),
            ),
          ),
        ),
        const SizedBox(height: 10),
        PairOrStack(
          gap: 8,
          children: [
            EntryField(
              icon: AppIcon.tag,
              label: l10n.contributionLabelHint,
              controller: _label,
              maxLength: maxContributionNote,
              compact: true,
              background: colors.ground,
            ),
            EntryField(
              icon: AppIcon.calendar,
              label: l10n.dateRowLabel(_date, widget.today, locale),
              onTap: _pickDate,
              compact: true,
              background: colors.ground,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (over)
          MessageBox(
            l10n.withdrawUpTo(formatter.formatCompact(widget.savedMinor)),
            kind: MessageKind.error,
          )
        else if (!_withdraw)
          MessageBox(l10n.savingNotSpending),
        const SizedBox(height: 12),
        MoneyKeypad(
          value: _minor,
          size: MoneyKeypadSize.sheet,
          onChanged: (minor) => setState(() => _minor = minor),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: _withdraw
              ? l10n.withdraw
              : l10n.contributionAddButton(formatter.formatCompact(_minor)),
          size: PrimaryButtonSize.sheet,
          onPressed: _minor > 0 && !over
              ? () => Navigator.of(context).pop((
                  withdraw: _withdraw,
                  amountMinor: _minor,
                  label: _label.text.trim(),
                  date: _date,
                ))
              : null,
        ),
      ],
    );
  }
}
