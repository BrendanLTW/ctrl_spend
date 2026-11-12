import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// Derived budget values (PRD §6.3, §8). Pure functions over minor units.

/// Budget state shared by the hero, budgets, categories and notifications.
enum BudgetStatus {
  /// Under 80% spent.
  neutral,

  /// 80–99% spent.
  warning,

  /// 100% or more spent.
  negative,

  /// No budget or limit is set.
  noBudget,
}

/// The status for [spentMinor] against [limitMinor]. Exact integer maths,
/// so 79.99% is still neutral. A limit of 0 is reached at once.
BudgetStatus budgetStatus({required int spentMinor, int? limitMinor}) {
  if (limitMinor == null) return BudgetStatus.noBudget;
  if (spentMinor >= limitMinor) return BudgetStatus.negative;
  if (spentMinor * 100 >= limitMinor * 80) return BudgetStatus.warning;
  return BudgetStatus.neutral;
}

/// Whole percent of [limitMinor] spent, rounded down so the label never
/// reads 80% while the status is still neutral. Can pass 100. Null when
/// there is no positive limit to measure against.
int? usedPercent({required int spentMinor, int? limitMinor}) {
  if (limitMinor == null || limitMinor <= 0) return null;
  return spentMinor * 100 ~/ limitMinor;
}

/// Expense and income totals for the transactions in [period].
({int spentMinor, int incomeMinor}) periodTotals(
  Iterable<Transaction> transactions,
  Period period,
) {
  var spent = 0;
  var income = 0;
  for (final t in transactions) {
    if (!period.contains(t.occurredAt)) continue;
    switch (t.type) {
      case TransactionType.expense:
        spent += t.amountMinor;
      case TransactionType.income:
        income += t.amountMinor;
    }
  }
  return (spentMinor: spent, incomeMinor: income);
}

/// Expense totals per category id for the transactions in [period].
/// Categories with no spending are absent.
Map<int, int> spentByCategory(
  Iterable<Transaction> transactions,
  Period period,
) {
  final spent = <int, int>{};
  for (final t in transactions) {
    if (t.type != TransactionType.expense) continue;
    if (!period.contains(t.occurredAt)) continue;
    spent.update(
      t.categoryId,
      (sum) => sum + t.amountMinor,
      ifAbsent: () => t.amountMinor,
    );
  }
  return spent;
}

/// Monthly budget − spent. Negative when over ("Over budget by").
/// Goal contributions are never transactions, so they can't affect it.
int leftToSpend({required int budgetMinor, required int spentMinor}) =>
    budgetMinor - spentMinor;

/// Sum of the limits on active expense categories. Archived categories
/// keep their limit but no longer take a share of the budget.
int allocated(Iterable<Category> categories) => categories
    .where((c) => c.type == TransactionType.expense && !c.archived)
    .fold(0, (sum, c) => sum + (c.limitMinor ?? 0));

/// The part of the budget not given to category limits.
int flexible({
  required int budgetMinor,
  required Iterable<Category> categories,
}) => budgetMinor - allocated(categories);

/// How much a limit on [categoryId] may be at most, so all limits fit in
/// [budgetMinor] (S06, S17). Null when there is no budget, so no cap.
int? maxLimitFor(
  int categoryId, {
  required Iterable<Category> categories,
  int? budgetMinor,
}) {
  if (budgetMinor == null) return null;
  final others = allocated(categories.where((c) => c.id != categoryId));
  return budgetMinor - others < 0 ? 0 : budgetMinor - others;
}

/// How far the category limits go over [budgetMinor], or null if they fit.
/// Use it to refuse lowering the budget below what's allocated.
int? limitsOverBudgetBy({
  required Iterable<Category> categories,
  int? budgetMinor,
}) {
  if (budgetMinor == null) return null;
  final over = allocated(categories) - budgetMinor;
  return over > 0 ? over : null;
}

/// [transactions] grouped by the start of their period, in one pass, so
/// summing several periods doesn't rescan every transaction for each
/// (S20, S25 with thousands of transactions).
Map<DateTime, List<Transaction>> transactionsByPeriod(
  Iterable<Transaction> transactions,
  MonthStartDay startDay,
) {
  final byStart = <DateTime, List<Transaction>>{};
  for (final t in transactions) {
    (byStart[periodFor(t.occurredAt, startDay).start] ??= []).add(t);
  }
  return byStart;
}
