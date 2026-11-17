import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/widgets/amount_sheet.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/l10n/app_localizations.dart';

/// The most a limit on [categoryId] may be, so all limits fit in
/// [budgetMinor], and S54's message for going over it: "Your limits would
/// add up to RM 2,200, which is more than your RM 2,000 monthly budget.
/// Food can be up to RM 1,500." No cap without a budget. A new category
/// passes an id no category has, so every existing limit counts.
({int? maxMinor, OverMessage? overMessage}) limitBounds(
  AppLocalizations l10n, {
  required int categoryId,
  required String categoryName,
  required Iterable<Category> categories,
  required int? budgetMinor,
  required Currency currency,
}) {
  final budget = budgetMinor;
  final max = maxLimitFor(
    categoryId,
    categories: categories,
    budgetMinor: budget,
  );
  if (budget == null || max == null) {
    return (maxMinor: null, overMessage: null);
  }
  final formatter = MoneyFormatter(currency);
  final others = budget - max;
  return (
    maxMinor: max,
    overMessage: (minor) {
      final most = formatter.formatCompact(max);
      return (
        text: l10n.limitsOverBudget(
          formatter.formatCompact(others + minor),
          formatter.formatCompact(budget),
          categoryName,
          most,
        ),
        bold: most,
      );
    },
  );
}
