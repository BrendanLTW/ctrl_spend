import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/month_calendar.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// S43 Picker · Date: a month calendar in a sheet with "Set 8 Nov".
/// Resolves to the chosen day (local midnight), or null if dismissed.
Future<DateTime?> showDatePickerSheet(
  BuildContext context, {
  required String title,
  required DateTime initial,
  required DateTime today,
  DateTime? firstDate,
  DateTime? lastDate,
}) => showAppSheet<DateTime>(
  context,
  title: title,
  builder: (_) => _DatePickerBody(
    initial: DateTime(initial.year, initial.month, initial.day),
    today: today,
    firstDate: firstDate,
    lastDate: lastDate,
  ),
);

class _DatePickerBody extends StatefulWidget {
  const new({
    required this.initial,
    required this.today,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initial;
  final DateTime today;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<_DatePickerBody> createState() => _DatePickerBodyState();
}

class _DatePickerBodyState extends State<_DatePickerBody> {
  late DateTime _selected = widget.initial;
  late DateTime _month = DateTime(widget.initial.year, widget.initial.month);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MonthCalendar(
          month: _month,
          today: widget.today,
          selected: _selected,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onSelected: (day) => setState(() => _selected = day),
          onMonthChanged: (month) => setState(() => _month = month),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: context.l10n.setDate(
            DateFormat('d MMM', locale).format(_selected),
          ),
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}
