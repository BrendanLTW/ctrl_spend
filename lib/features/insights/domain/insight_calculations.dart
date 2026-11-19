import 'dart:math';

import 'package:ctrlspend/core/period/period.dart';
import 'package:ctrlspend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrlspend/features/periods/domain/period_snapshot.dart';
import 'package:ctrlspend/features/transactions/domain/transaction.dart';

/// Insights calculations (PRD §5.7). Pure functions over minor units.

/// "A few days" of spending (S40): Insights charts nothing until there
/// are expenses on this many different local days.
const minSpendingDays = 3;

/// Whether [transactions] have expenses on at least [minSpendingDays]
/// different local days, ever. Income doesn't count.
bool hasEnoughSpending(Iterable<Transaction> transactions) {
  final days = <(int, int, int)>{};
  for (final t in transactions) {
    if (t.type != TransactionType.expense) continue;
    final local = t.occurredAt.toLocal();
    days.add((local.year, local.month, local.day));
    if (days.length >= minSpendingDays) return true;
  }
  return false;
}

typedef CategoryShare = ({int categoryId, int spentMinor, int percent});

/// Spending per category in [period], largest first (S18). Percents are
/// whole numbers that add up to exactly 100 (largest remainder).
List<CategoryShare> categoryShares(
  Iterable<Transaction> transactions,
  Period period,
) {
  final spent = spentByCategory(transactions, period).entries.toList()
    ..sort((a, b) => b.value != a.value ? b.value - a.value : a.key - b.key);
  final total = spent.fold(0, (sum, e) => sum + e.value);
  if (total == 0) return [];

  final percents = [for (final e in spent) e.value * 100 ~/ total];
  final byRemainder = List.generate(spent.length, (i) => i)
    ..sort((a, b) {
      final ra = spent[a].value * 100 % total;
      final rb = spent[b].value * 100 % total;
      return ra != rb ? rb - ra : a - b;
    });
  final missing = 100 - percents.fold<int>(0, (sum, p) => sum + p);
  for (final i in byRemainder.take(missing)) {
    percents[i]++;
  }
  return [
    for (final (i, e) in spent.indexed)
      (categoryId: e.key, spentMinor: e.value, percent: percents[i]),
  ];
}

/// Monthly budget ÷ days in [period], rounded for display (S19's pace
/// line). Comparisons use [isUnderPace], which is exact.
int? dailyPace({required Period period, int? budgetMinor}) {
  if (budgetMinor == null) return null;
  final days = period.days;
  return (budgetMinor + days ~/ 2) ~/ days;
}

/// Whether [spentMinor] in one day of [period] is at or under the pace.
/// Null without a budget.
bool? isUnderPace({
  required int spentMinor,
  required Period period,
  int? budgetMinor,
}) => budgetMinor == null ? null : spentMinor * period.days <= budgetMinor;

typedef DaySpend = ({
  DateTime day,
  int spentMinor,
  Transaction? largest,
  bool? underPace,
});

typedef WeekSummary = ({
  List<DaySpend> days,
  int totalMinor,
  int averageMinor,
  int? underPaceDays,
  DaySpend? biggestDay,
});

/// The 7 local days ending [today], oldest first (S19). Each day is judged
/// against the pace of its own period.
WeekSummary lastSevenDays(
  Iterable<Transaction> transactions, {
  required DateTime today,
  required MonthStartDay startDay,
  int? budgetMinor,
}) {
  final local = today.toLocal();
  final dayList = [
    for (var i = 6; i >= 0; i--)
      DateTime(local.year, local.month, local.day - i),
  ];
  final byDay = <DateTime, List<Transaction>>{for (final d in dayList) d: []};
  for (final t in transactions) {
    if (t.type != TransactionType.expense) continue;
    final at = t.occurredAt.toLocal();
    byDay[DateTime(at.year, at.month, at.day)]?.add(t);
  }

  final days = <DaySpend>[
    for (final day in dayList)
      _daySpend(day, byDay[day]!, periodFor(day, startDay), budgetMinor),
  ];
  final total = days.fold(0, (sum, d) => sum + d.spentMinor);
  DaySpend? biggest;
  for (final d in days) {
    // >= so a tie goes to the more recent day.
    if (d.spentMinor > 0 && d.spentMinor >= (biggest?.spentMinor ?? 0)) {
      biggest = d;
    }
  }
  return (
    days: days,
    totalMinor: total,
    averageMinor: (total + 3) ~/ 7,
    underPaceDays: budgetMinor == null
        ? null
        : days.where((d) => d.underPace!).length,
    biggestDay: biggest,
  );
}

DaySpend _daySpend(
  DateTime day,
  List<Transaction> spending,
  Period period,
  int? budgetMinor,
) {
  final spent = spending.fold(0, (sum, t) => sum + t.amountMinor);
  Transaction? largest;
  for (final t in spending) {
    if (t.amountMinor > (largest?.amountMinor ?? 0)) largest = t;
  }
  return (
    day: day,
    spentMinor: spent,
    largest: largest,
    underPace: isUnderPace(
      spentMinor: spent,
      period: period,
      budgetMinor: budgetMinor,
    ),
  );
}

typedef PeriodSpend = ({
  Period period,
  int spentMinor,
  bool soFar,
  bool? overBudget,
});

typedef TrendSummary = ({
  List<PeriodSpend> periods,
  List<PeriodSpend> full,
  int? averageMinor,
  int? underBudgetCount,
  PeriodSpend? highest,
});

/// The last [count] periods up to the one containing [today], oldest
/// first (S20). The current one is "so far", against [budgetMinor]. The
/// full periods before it are the latest [snapshots], each against the
/// budget it saved (PRD §5.10); earlier slots with no snapshot are empty
/// periods, not full. Averages, the under-budget count and the highest
/// period use full periods only.
TrendSummary recentPeriods(
  Iterable<Transaction> transactions, {
  required DateTime today,
  required MonthStartDay startDay,
  Iterable<PeriodSnapshot> snapshots = const [],
  int? budgetMinor,
  int count = 6,
}) {
  final current = periodFor(today, startDay);
  final saved = [
    for (final s in snapshots)
      if (s.period.start.isBefore(current.start)) s,
  ]..sort((a, b) => a.period.start.compareTo(b.period.start));
  final shown = saved.skip(max(0, saved.length - (count - 1))).toList();
  final periods = <Period>[for (final s in shown) s.period, current];
  while (periods.length < count) {
    final start = periods.first.start;
    periods.insert(
      0,
      periodFor(DateTime(start.year, start.month, start.day - 1), startDay),
    );
  }
  final budgets = {for (final s in shown) s.period.start: s.budgetMinor};

  final spends = <PeriodSpend>[];
  for (final (i, p) in periods.indexed) {
    final spent = periodTotals(transactions, p).spentMinor;
    final budget = i == periods.length - 1 ? budgetMinor : budgets[p.start];
    spends.add((
      period: p,
      spentMinor: spent,
      soFar: i == periods.length - 1,
      overBudget: budget == null
          ? null
          : budgetStatus(spentMinor: spent, limitMinor: budget) ==
                BudgetStatus.negative,
    ));
  }
  final full = [
    for (final s in spends)
      if (!s.soFar && budgets.containsKey(s.period.start)) s,
  ];
  PeriodSpend? highest;
  for (final s in full) {
    if (s.spentMinor >= (highest?.spentMinor ?? -1)) highest = s;
  }
  final fullTotal = full.fold(0, (sum, s) => sum + s.spentMinor);
  return (
    periods: spends,
    full: full,
    averageMinor: full.isEmpty
        ? null
        : (fullTotal + full.length ~/ 2) ~/ full.length,
    underBudgetCount: full.every((s) => s.overBudget == null)
        ? null
        : full.where((s) => s.overBudget == false).length,
    highest: highest,
  );
}
