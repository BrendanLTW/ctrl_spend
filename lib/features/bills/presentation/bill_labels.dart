import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// How soon a bill is due, for its S27 row colour.
enum DueSoon { overdue, soon, later }

/// Bills due within this many days show in the warning colour (S27).
const soonDays = 7;

/// Whole local days from [today] to [due]: 0 today, -1 yesterday.
int daysUntil(DateTime due, DateTime today) {
  final from = DateTime.utc(today.year, today.month, today.day);
  return DateTime.utc(due.year, due.month, due.day).difference(from).inDays;
}

DueSoon dueSoon(DateTime due, DateTime today) =>
    switch (daysUntil(due, today)) {
      < 0 => DueSoon.overdue,
      <= soonDays => DueSoon.soon,
      _ => DueSoon.later,
    };

extension BillLabels on AppLocalizations {
  /// S27's second line: "Due 8 Nov · in 4 days", "Overdue · due 2 Nov".
  String dueLabel(DateTime due, DateTime today, String locale) {
    final date = DateFormat('d MMM', locale).format(due);
    return switch (dueSoon(due, today)) {
      DueSoon.overdue => billOverdue(date),
      DueSoon.soon => billDueSoon(date, daysUntil(due, today)),
      DueSoon.later => billDue(date),
    };
  }

  /// S28's Repeats value and S44's choices.
  String repeatLabel(BillRepeat repeat) => switch (repeat) {
    BillRepeat(unit: RepeatUnit.week, every: 1) => repeatWeekly,
    BillRepeat(unit: RepeatUnit.week, every: 2) => repeatFortnightly,
    BillRepeat(unit: RepeatUnit.month, every: 1) => repeatMonthly,
    BillRepeat(unit: RepeatUnit.month, every: 3) => repeatQuarterly,
    BillRepeat(unit: RepeatUnit.year, every: 1) => repeatYearly,
    BillRepeat(unit: RepeatUnit.day, :final every) => repeatEveryDays(every),
    BillRepeat(unit: RepeatUnit.week, :final every) => repeatEveryWeeks(every),
    BillRepeat(unit: RepeatUnit.month, :final every) => repeatEveryMonths(
      every,
    ),
    BillRepeat(unit: RepeatUnit.year, :final every) => repeatEveryYears(every),
  };
}
