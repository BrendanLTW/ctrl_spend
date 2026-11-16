import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// S48's "Remind me at": an hour and minute wheel and Save. Resolves to
/// the chosen minutes after midnight, or null when closed.
Future<int?> showReminderTimeSheet(
  BuildContext context, {
  required int minutes,
}) => showAppSheet<int>(
  context,
  title: context.l10n.remindMeAt,
  builder: (_) => _ReminderTimeBody(initial: minutes),
);

class _ReminderTimeBody extends StatefulWidget {
  const new({required this.initial});

  final int initial;

  @override
  State<_ReminderTimeBody> createState() => _ReminderTimeBodyState();
}

class _ReminderTimeBodyState extends State<_ReminderTimeBody> {
  late int _minutes = widget.initial;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 216,
          child: CupertinoTheme(
            data: CupertinoThemeData(
              brightness: Theme.of(context).brightness,
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: context.text.keypadKey.copyWith(
                  color: colors.ink,
                ),
              ),
            ),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime(
                2000,
                1,
                1,
                _minutes ~/ 60,
                _minutes % 60,
              ),
              use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
              onDateTimeChanged: (t) => _minutes = t.hour * 60 + t.minute,
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: context.l10n.save,
          size: PrimaryButtonSize.sheet,
          onPressed: () => Navigator.of(context).pop(_minutes),
        ),
      ],
    );
  }
}
