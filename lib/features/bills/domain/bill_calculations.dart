import 'dart:math';

import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';

/// One payment of a bill, due on a local calendar date.
typedef BillPayment = ({Bill bill, DateTime due});

/// The due date one [repeat] after [due]. Days and weeks count calendar
/// days, so a daylight-saving change can't shift it; months and years go
/// back to [BillRepeat.day], or the month's last day if it is shorter
/// (31 Jan → 28 Feb → 31 Mar).
DateTime nextDue(DateTime due, BillRepeat repeat) {
  final every = repeat.every;
  final day = repeat.day ?? due.day;
  return switch (repeat.unit) {
    RepeatUnit.day => DateTime(due.year, due.month, due.day + every),
    RepeatUnit.week => DateTime(due.year, due.month, due.day + 7 * every),
    RepeatUnit.month => _onDay(due.year, due.month + every, day),
    RepeatUnit.year => _onDay(due.year + every, due.month, day),
  };
}

DateTime _onDay(int year, int month, int day) {
  // DateTime normalises month 13 and day 0.
  final first = DateTime(year, month);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, min(day, last));
}

/// Every unpaid payment due by the end of [period], soonest first. A
/// weekly bill can be due more than once, and overdue payments count:
/// they are still to be paid. Paused bills are left out (PRD §5.11).
List<BillPayment> paymentsDue(Iterable<Bill> bills, Period period) => [
  for (final bill in bills.where((b) => !b.paused))
    for (
      var due = bill.nextDue;
      !due.isAfter(period.end);
      due = nextDue(due, bill.repeat)
    )
      (bill: bill, due: due),
]..sort((a, b) => a.due.compareTo(b.due));

/// "Left after bills" (PRD §8): left to spend minus the payments [due].
/// Shown on S27 only; null without a monthly budget.
int? leftAfterBills({
  required int? budgetMinor,
  required int spentMinor,
  required Iterable<BillPayment> due,
}) => budgetMinor == null
    ? null
    : leftToSpend(budgetMinor: budgetMinor, spentMinor: spentMinor) -
          due.fold(0, (sum, p) => sum + p.bill.amountMinor);
