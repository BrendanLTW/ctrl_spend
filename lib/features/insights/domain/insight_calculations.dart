import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// Insights calculations (PRD §5.7). Pure functions over minor units.

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
/// first (S20). The current one is "so far". Averages, the under-budget
/// count and the highest period use full periods only: finished, and not
/// before the period of the first transaction.
TrendSummary recentPeriods(
  Iterable<Transaction> transactions, {
  required DateTime today,
  required MonthStartDay startDay,
  int? budgetMinor,
  int count = 6,
}) {
  final periods = <Period>[periodFor(today, startDay)];
  while (periods.length < count) {
    final start = periods.first.start;
    periods.insert(
      0,
      periodFor(DateTime(start.year, start.month, start.day - 1), startDay),
    );
  }

  DateTime? first;
  for (final t in transactions) {
    if (first == null || t.occurredAt.isBefore(first)) first = t.occurredAt;
  }
  final firstStart = first == null ? null : periodFor(first, startDay).start;

  final byPeriod = transactionsByPeriod(transactions, startDay);
  final spends = <PeriodSpend>[];
  for (final (i, p) in periods.indexed) {
    final spent = periodTotals(byPeriod[p.start] ?? const [], p).spentMinor;
    spends.add((
      period: p,
      spentMinor: spent,
      soFar: i == periods.length - 1,
      overBudget: budgetMinor == null
          ? null
          : budgetStatus(spentMinor: spent, limitMinor: budgetMinor) ==
                BudgetStatus.negative,
    ));
  }
  final full = [
    for (final s in spends)
      if (!s.soFar &&
          firstStart != null &&
          !s.period.start.isBefore(firstStart))
        s,
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
    underBudgetCount: budgetMinor == null || full.isEmpty
        ? null
        : full.where((s) => !s.overBudget!).length,
    highest: highest,
  );
}
