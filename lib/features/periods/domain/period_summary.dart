import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// One category's result in a period (S26). `leftMinor` is limit − spent:
/// above 0 is "RM 90 under", 0 or below is over. Null means "No limit".
typedef CategoryResult = ({int categoryId, int spentMinor, int? leftMinor});

/// A period's result (S25, S26). `leftMinor` is budget − spent, read like
/// `CategoryResult.leftMinor`; null when there's no budget.
typedef PeriodSummary = ({
  Period period,
  int spentMinor,
  int? leftMinor,
  List<CategoryResult> categories,
});

/// Sums [period] against today's budget and limits: the app keeps no
/// budget history, so changing them changes past results too.
/// Categories are those that spent in the period or have a limit, largest
/// spend first, then in display order.
PeriodSummary periodSummary(
  Iterable<Transaction> transactions, {
  required Period period,
  required Iterable<Category> categories,
  int? budgetMinor,
}) {
  final spent = spentByCategory(transactions, period);
  final listed =
      [
        for (final c in categories)
          if (c.type == TransactionType.expense &&
              (spent.containsKey(c.id) ||
                  (c.limitMinor != null && !c.archived)))
            c,
      ]..sort((a, b) {
        final bySpend = (spent[b.id] ?? 0) - (spent[a.id] ?? 0);
        return bySpend != 0 ? bySpend : a.sortOrder - b.sortOrder;
      });
  final results = [
    for (final c in listed)
      (
        categoryId: c.id,
        spentMinor: spent[c.id] ?? 0,
        leftMinor: c.limitMinor == null
            ? null
            : leftToSpend(
                budgetMinor: c.limitMinor!,
                spentMinor: spent[c.id] ?? 0,
              ),
      ),
  ];
  final total = periodTotals(transactions, period).spentMinor;
  return (
    period: period,
    spentMinor: total,
    leftMinor: budgetMinor == null
        ? null
        : leftToSpend(budgetMinor: budgetMinor, spentMinor: total),
    categories: results,
  );
}
