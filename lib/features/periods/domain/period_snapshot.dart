import 'package:ctrlspend/core/period/period.dart';
import 'package:ctrlspend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrlspend/features/categories/domain/category.dart';
import 'package:ctrlspend/features/periods/domain/period_summary.dart';
import 'package:ctrlspend/features/transactions/domain/transaction.dart';

/// A period's budget, limits and totals, saved once it has ended (PRD
/// §6.2, §8), so later budget changes don't rewrite history. S25, S26 and
/// S20 take the budget and limits from here; spent and income are read
/// live from the transactions, so later edits still show, and the stored
/// totals are a record of how it stood.
typedef PeriodSnapshot = ({
  Period period,
  int? budgetMinor,

  /// Category id → its monthly limit, for categories that had one.
  Map<int, int> limits,
  int spentMinor,
  int incomeMinor,
});

/// The snapshots to write now: one for each ended period that ends after
/// the latest of [existing], back to the first transaction. An app can't
/// run when a period ends, so this runs on launch and resume, and each
/// one takes the budget and limits as they are now: for periods that
/// ended long ago, an approximation (backfill). Comparing with the latest
/// end means a month-start change never rewrites or doubles old ones.
List<PeriodSnapshot> snapshotsToWrite({
  required Iterable<PeriodSnapshot> existing,
  required Iterable<Transaction> transactions,
  required Iterable<Category> categories,
  required DateTime today,
  required MonthStartDay startDay,
  required int? budgetMinor,
}) {
  DateTime? first;
  for (final t in transactions) {
    if (first == null || t.occurredAt.isBefore(first)) first = t.occurredAt;
  }
  DateTime? latestEnd;
  for (final s in existing) {
    if (latestEnd == null || s.period.end.isAfter(latestEnd)) {
      latestEnd = s.period.end;
    }
  }
  final limits = {
    for (final c in categories)
      if (c.type == TransactionType.expense && c.limitMinor != null)
        c.id: c.limitMinor!,
  };
  final byPeriod = transactionsByPeriod(transactions, startDay);
  return [
    for (final p in previousPeriods(
      today: today,
      startDay: startDay,
      since: first,
    ).reversed)
      if (latestEnd == null || p.end.isAfter(latestEnd))
        () {
          final totals = periodTotals(byPeriod[p.start] ?? const [], p);
          return (
            period: p,
            budgetMinor: budgetMinor,
            limits: limits,
            spentMinor: totals.spentMinor,
            incomeMinor: totals.incomeMinor,
          );
        }(),
  ];
}

/// [categories] with the limits [snapshot] saved, for its period's results
/// (S26): a category without a saved limit had none then.
List<Category> withSnapshotLimits(
  Iterable<Category> categories,
  PeriodSnapshot snapshot,
) => [
  for (final c in categories) c.copyWith(limitMinor: snapshot.limits[c.id]),
];
