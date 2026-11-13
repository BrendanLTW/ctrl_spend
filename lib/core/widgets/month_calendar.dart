import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A month of days, weeks starting Monday (DESIGN §7, S43). Controlled:
/// the screen holds [month] and [selected]. Days outside [firstDate] to
/// [lastDate] are disabled, e.g. future days for a transaction date.
class MonthCalendar extends StatelessWidget {
  const new({
    required this.month,
    required this.today,
    required this.onSelected,
    required this.onMonthChanged,
    this.selected,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  /// Any day in the month to show.
  final DateTime month;
  final DateTime today;
  final DateTime? selected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onSelected;

  /// Called with the first day of the previous or next month.
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday = 1, so this many blanks before the 1st.
    final leading = first.weekday - 1;
    final firstDay = firstDate == null ? null : _day(firstDate!);
    final lastDay = lastDate == null ? null : _day(lastDate!);
    final canGoBack =
        firstDay == null ||
        first.isAfter(DateTime(firstDay.year, firstDay.month));
    final canGoForward =
        lastDay == null ||
        DateTime(
          month.year,
          month.month + 1,
        ).isBefore(DateTime(lastDay.year, lastDay.month + 1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _MonthButton(
              icon: AppIcon.chevronLeft,
              tooltip: l10n.previousMonth,
              onPressed: canGoBack
                  ? () => onMonthChanged(DateTime(month.year, month.month - 1))
                  : null,
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMM(locale).format(first),
                textAlign: TextAlign.center,
                style: text.rowTitle.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _MonthButton(
              icon: AppIcon.chevronRight,
              tooltip: l10n.nextMonth,
              onPressed: canGoForward
                  ? () => onMonthChanged(DateTime(month.year, month.month + 1))
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ExcludeSemantics(
          child: Row(
            children: [
              // 5 Jan 2026 is a Monday.
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    DateFormat.EEEEE(locale).format(DateTime(2026, 1, 5 + i)),
                    textAlign: TextAlign.center,
                    style: text.caption.copyWith(
                      color: colors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (var week = 0; week * 7 < leading + daysInMonth; week++)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _cell(
                      week * 7 + col - leading + 1,
                      daysInMonth: daysInMonth,
                      firstDay: firstDay,
                      lastDay: lastDay,
                      locale: locale,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(
    int day, {
    required int daysInMonth,
    required DateTime? firstDay,
    required DateTime? lastDay,
    required String locale,
  }) {
    if (day < 1 || day > daysInMonth) return const SizedBox(height: 44);
    final date = DateTime(month.year, month.month, day);
    return _Day(
      date: date,
      isToday: _sameDay(date, today),
      isSelected: selected != null && _sameDay(date, selected!),
      enabled:
          (firstDay == null || !date.isBefore(firstDay)) &&
          (lastDay == null || !date.isAfter(lastDay)),
      locale: locale,
      onTap: onSelected,
    );
  }
}

DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _MonthButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final AppIcon icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        fixedSize: const Size(48, 48),
        backgroundColor: colors.raised,
        foregroundColor: colors.ink,
        disabledBackgroundColor: colors.raised,
        disabledForegroundColor: colors.disabled,
      ),
      icon: AppIconView(icon, size: 22),
    );
  }
}

class _Day extends StatelessWidget {
  const new({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.enabled,
    required this.locale,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool enabled;
  final String locale;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.rowTitle.copyWith(
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      color: isSelected
          ? colors.onInk
          : enabled
          ? colors.ink
          : colors.disabled,
    );
    return Semantics(
      button: enabled,
      selected: isSelected,
      enabled: enabled,
      label: DateFormat.yMMMMEEEEd(locale).format(date),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onTap(date) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? colors.ink : null,
              borderRadius: BorderRadius.circular(14),
              border: isToday && !isSelected
                  ? Border.all(color: colors.control, width: 2)
                  : null,
            ),
            child: Text('${date.day}', style: style),
          ),
        ),
      ),
    );
  }
}
