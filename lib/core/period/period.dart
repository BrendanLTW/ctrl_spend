/// The day a budget period starts each month (PRD §6.2).
sealed class MonthStartDay {
  const new();
}

/// A fixed day, 1–28, so every month has it.
final class DayOfMonth extends MonthStartDay {
  const new(this.day) : assert(day >= 1 && day <= 28, 'day 1–28');

  final int day;
}

/// The last day of each month: 31 Jan, 28 or 29 Feb, 31 Mar…
final class LastDayOfMonth extends MonthStartDay {
  const new();
}

/// A budget period: `start` to `end`, both inclusive, as local dates at
/// midnight. A record, so two periods with the same dates are equal.
typedef Period = ({DateTime start, DateTime end});

extension PeriodDays on Period {
  /// Number of calendar days, counting both ends.
  int get days =>
      DateTime.utc(
        end.year,
        end.month,
        end.day,
      ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
      1;

  /// Whether [date]'s local calendar day falls in this period.
  bool contains(DateTime date) {
    final day = _localDay(date);
    return !day.isBefore(start) && !day.isAfter(end);
  }
}

/// The period containing [date]'s local calendar day. A period runs from
/// the start day to the day before it next month (15 Oct – 14 Nov). Use
/// this everywhere; never compute period bounds inline.
Period periodFor(DateTime date, MonthStartDay startDay) {
  final day = _localDay(date);
  var start = _startIn(day.year, day.month, startDay);
  if (day.isBefore(start)) {
    start = _startIn(day.year, day.month - 1, startDay);
  }
  final next = _startIn(start.year, start.month + 1, startDay);
  // DateTime normalises day 0 and month 0, so this crosses month and year
  // ends and stays on the calendar day across DST changes.
  return (start: start, end: DateTime(next.year, next.month, next.day - 1));
}

DateTime _startIn(int year, int month, MonthStartDay startDay) =>
    switch (startDay) {
      DayOfMonth(:final day) => DateTime(year, month, day),
      LastDayOfMonth() => DateTime(year, month + 1, 0),
    };

DateTime _localDay(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}
