import 'package:ctrlspend/l10n/app_localizations.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:intl/intl.dart';

extension DateLabels on AppLocalizations {
  /// "Today", "Yesterday" or "3 Nov" for [date]'s local day, relative to
  /// [today].
  String dayLabel(DateTime date, DateTime today, String locale) {
    final local = date.toLocal();
    final day = DateTime.utc(local.year, local.month, local.day);
    final now = DateTime.utc(today.year, today.month, today.day);
    return switch (now.difference(day).inDays) {
      0 => this.today,
      1 => yesterday,
      _ => DateFormat('d MMM', locale).format(local),
    };
  }
}

extension DateRowLabels on AppLocalizations {
  /// The date row on S12/S13: "Today, 4 Nov", "Yesterday, 3 Nov" or
  /// "Mon, 2 Nov".
  String dateRowLabel(DateTime date, DateTime today, String locale) {
    final dayMonth = DateFormat('d MMM', locale).format(date);
    final day = DateTime.utc(date.year, date.month, date.day);
    final now = DateTime.utc(today.year, today.month, today.day);
    return switch (now.difference(day).inDays) {
      0 => dateToday(dayMonth),
      1 => dateYesterday(dayMonth),
      _ => DateFormat('EEE, d MMM', locale).format(date),
    };
  }
}

extension DayHeaderLabels on AppLocalizations {
  /// Activity's day header (S16): "Today", "Yesterday, 3 Nov" or
  /// "Sun, 1 Nov". Shown uppercase.
  String dayHeaderLabel(DateTime day, DateTime today, String locale) {
    final date = DateTime.utc(day.year, day.month, day.day);
    final now = DateTime.utc(today.year, today.month, today.day);
    return switch (now.difference(date).inDays) {
      0 => this.today,
      1 => dateYesterday(DateFormat('d MMM', locale).format(day)),
      _ => DateFormat('EEE, d MMM', locale).format(day),
    };
  }
}

/// S52's "1 Jan – 4 Nov 2026": the year once when both days share it,
/// one day when they're the same.
String dayRangeLabel(DateTime first, DateTime last, String locale) {
  final full = DateFormat('d MMM yyyy', locale);
  if (DateUtils.isSameDay(first, last)) return full.format(first);
  final start = first.year == last.year
      ? DateFormat('d MMM', locale).format(first)
      : full.format(first);
  return '$start – ${full.format(last)}';
}

/// S53's "Jan – Nov 2026", from [start]'s month to [end]'s.
String monthRangeLabel(DateTime start, DateTime end, String locale) {
  final full = DateFormat('MMM yyyy', locale);
  if (start.year == end.year && start.month == end.month) {
    return full.format(end);
  }
  final from = start.year == end.year
      ? DateFormat('MMM', locale).format(start)
      : full.format(start);
  return '$from – ${full.format(end)}';
}
