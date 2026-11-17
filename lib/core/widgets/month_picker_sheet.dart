import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A month and year in a sheet, for S31's Target date: the year with
/// arrows, its 12 months and "Set Dec 2027". Months before [firstMonth]
/// can't be picked. Resolves to the first of the month, or null if
/// dismissed. Not on the canvas (see docs/design-notes.md).
Future<DateTime?> showMonthPickerSheet(
  BuildContext context, {
  required String title,
  required DateTime initial,
  required DateTime firstMonth,
}) => showAppSheet<DateTime>(
  context,
  title: title,
  builder: (_) => _MonthPickerBody(
    initial: DateTime(initial.year, initial.month),
    firstMonth: DateTime(firstMonth.year, firstMonth.month),
  ),
);

class _MonthPickerBody extends StatefulWidget {
  const new({required this.initial, required this.firstMonth});

  final DateTime initial;
  final DateTime firstMonth;

  @override
  State<_MonthPickerBody> createState() => _MonthPickerBodyState();
}

class _MonthPickerBodyState extends State<_MonthPickerBody> {
  late DateTime _selected = widget.initial;
  late int _year = widget.initial.year;

  static const _perRow = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final canGoBack = _year > widget.firstMonth.year;

    Widget arrow(AppIcon icon, String tooltip, int by, {bool enabled = true}) =>
        IconButton(
          tooltip: tooltip,
          onPressed: enabled ? () => setState(() => _year += by) : null,
          icon: AppIconView(
            icon,
            stroke: AppIconStroke.chevron,
            size: 22,
            color: enabled ? colors.ink : colors.disabled,
          ),
        );

    Widget month(int m) {
      final date = DateTime(_year, m);
      final enabled = !date.isBefore(widget.firstMonth);
      final chosen = date == _selected;
      return Semantics(
        button: enabled,
        enabled: enabled,
        selected: chosen,
        label: DateFormat.yMMMM(locale).format(date),
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => setState(() => _selected = date) : null,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: chosen ? colors.ink : null,
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            child: Text(
              DateFormat.MMM(locale).format(date),
              style: text.rowTitle.copyWith(
                color: chosen
                    ? colors.onInk
                    : enabled
                    ? colors.ink
                    : colors.disabled,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            arrow(
              AppIcon.chevronLeft,
              l10n.previousYear,
              -1,
              enabled: canGoBack,
            ),
            Expanded(
              child: Text(
                '$_year',
                textAlign: TextAlign.center,
                style: text.header.copyWith(color: colors.ink),
              ),
            ),
            arrow(AppIcon.chevronRight, l10n.nextYear, 1),
          ],
        ),
        const SizedBox(height: 12),
        for (var row = 0; row < 12 ~/ _perRow; row++)
          Padding(
            padding: EdgeInsets.only(top: row == 0 ? 0 : 8),
            child: Row(
              children: [
                for (var col = 0; col < _perRow; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(child: month(row * _perRow + col + 1)),
                ],
              ],
            ),
          ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: l10n.setMonth(DateFormat('MMM y', locale).format(_selected)),
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}
