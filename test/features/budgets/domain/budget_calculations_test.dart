import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

final Period period = periodFor(DateTime(2026, 11, 6), const DayOfMonth(15));

var _nextId = 1;

Transaction tx(
  int amountMinor, {
  int categoryId = 1,
  TransactionType type = TransactionType.expense,
  DateTime? at,
}) => Transaction(
  id: _nextId++,
  amountMinor: amountMinor,
  type: type,
  categoryId: categoryId,
  occurredAt: (at ?? DateTime(2026, 11, 6, 12)).toUtc(),
  title: 'x',
);

Category category(
  int id, {
  int? limitMinor,
  TransactionType type = TransactionType.expense,
  bool archived = false,
}) => Category(
  id: id,
  name: 'Category $id',
  type: type,
  iconKey: CategoryIconKey.food,
  colorKey: CategoryColorKey.orange,
  sortOrder: id,
  limitMinor: limitMinor,
  archived: archived,
);

void main() {
  group('budgetStatus', () {
    BudgetStatus status(int spent, [int? limit = 200000]) =>
        budgetStatus(spentMinor: spent, limitMinor: limit);

    test('under 80% is neutral', () {
      expect(status(0), BudgetStatus.neutral);
      expect(status(76000), BudgetStatus.neutral);
      expect(status(159999), BudgetStatus.neutral, reason: '79.9995%');
    });

    test('80–99% is warning', () {
      expect(status(160000), BudgetStatus.warning, reason: 'exactly 80%');
      expect(status(184000), BudgetStatus.warning);
      expect(status(199999), BudgetStatus.warning, reason: '99.9995%');
    });

    test('100% or more is negative', () {
      expect(status(200000), BudgetStatus.negative, reason: 'exactly 100%');
      expect(status(201000), BudgetStatus.negative);
    });

    test('no limit is noBudget, whatever was spent', () {
      expect(status(0, null), BudgetStatus.noBudget);
      expect(status(999999, null), BudgetStatus.noBudget);
    });

    test('a limit of 0 is reached at once', () {
      expect(status(0, 0), BudgetStatus.negative);
    });

    test('works for small category limits (RM 400)', () {
      expect(status(31999, 40000), BudgetStatus.neutral);
      expect(status(32800, 40000), BudgetStatus.warning, reason: '82%');
      expect(status(51200, 40000), BudgetStatus.negative);
    });
  });

  group('usedPercent', () {
    int? percent(int spent, [int? limit = 40000]) =>
        usedPercent(spentMinor: spent, limitMinor: limit);

    test('rounds down, so the label agrees with the status', () {
      expect(percent(32800), 82);
      expect(percent(31999), 79, reason: '79.9975% is still neutral');
      expect(percent(39999), 99);
      expect(percent(40000), 100);
    });

    test('can pass 100', () {
      expect(percent(51200), 128);
    });

    test('is null without a positive limit', () {
      expect(percent(100, null), isNull);
      expect(percent(100, 0), isNull);
    });
  });

  group('periodTotals', () {
    test('sums expenses and income separately', () {
      final totals = periodTotals([
        tx(1250),
        tx(3000),
        tx(250000, categoryId: 7, type: TransactionType.income),
      ], period);
      expect(totals.spentMinor, 4250);
      expect(totals.incomeMinor, 250000);
    });

    test('ignores transactions outside the period', () {
      final totals = periodTotals([
        tx(100, at: DateTime(2026, 10, 14, 23, 59)),
        tx(200, at: DateTime(2026, 10, 15)),
        tx(400, at: DateTime(2026, 11, 14, 23, 59)),
        tx(800, at: DateTime(2026, 11, 15)),
      ], period);
      expect(totals.spentMinor, 600);
    });

    test('is zero with no transactions (first run, S10)', () {
      expect(periodTotals([], period), (spentMinor: 0, incomeMinor: 0));
    });
  });

  test('spentByCategory sums expenses per category in the period', () {
    final spent = spentByCategory([
      tx(1000),
      tx(500),
      tx(300, categoryId: 2),
      tx(250000, categoryId: 7, type: TransactionType.income),
      tx(9999, categoryId: 2, at: DateTime(2026, 9, 3)),
    ], period);
    expect(spent, {1: 1500, 2: 300});
  });

  group('leftToSpend', () {
    test('is budget minus spent', () {
      expect(leftToSpend(budgetMinor: 200000, spentMinor: 76000), 124000);
    });

    test('goes negative when over budget', () {
      expect(leftToSpend(budgetMinor: 200000, spentMinor: 201000), -1000);
    });
  });

  group('allocated and flexible', () {
    final categories = [
      category(1, limitMinor: 40000),
      category(2, limitMinor: 30000),
      category(3),
      category(4, limitMinor: 20000, archived: true),
      category(7, limitMinor: 5000, type: TransactionType.income),
    ];

    test('allocated sums active expense limits only', () {
      expect(allocated(categories), 70000);
      expect(allocated([]), 0);
    });

    test('flexible is the budget left after limits', () {
      expect(flexible(budgetMinor: 200000, categories: categories), 130000);
    });
  });

  group('limit validation', () {
    final categories = [
      category(1, limitMinor: 40000),
      category(2, limitMinor: 30000),
      category(3),
    ];

    test('a category may take what the others leave', () {
      expect(
        maxLimitFor(3, categories: categories, budgetMinor: 100000),
        30000,
      );
      expect(
        maxLimitFor(1, categories: categories, budgetMinor: 100000),
        70000,
        reason: 'its own current limit does not count against it',
      );
    });

    test('the cap never goes below 0', () {
      expect(maxLimitFor(3, categories: categories, budgetMinor: 50000), 0);
    });

    test('no budget means no cap', () {
      expect(maxLimitFor(3, categories: categories), isNull);
      expect(limitsOverBudgetBy(categories: categories), isNull);
    });

    test('limitsOverBudgetBy reports the excess, or null if they fit', () {
      expect(
        limitsOverBudgetBy(categories: categories, budgetMinor: 70000),
        isNull,
        reason: 'exactly allocated fits',
      );
      expect(
        limitsOverBudgetBy(categories: categories, budgetMinor: 60000),
        10000,
      );
    });
  });

  test('transactionsByPeriod groups by period start in one pass', () {
    final late = tx(100, at: DateTime(2026, 10, 14, 23, 59));
    final early = tx(200, at: DateTime(2026, 10, 15));
    final nov = tx(300, at: DateTime(2026, 11, 14, 12));
    final grouped = transactionsByPeriod([
      late,
      early,
      nov,
    ], const DayOfMonth(15));
    expect(grouped, {
      DateTime(2026, 9, 15): [late],
      DateTime(2026, 10, 15): [early, nov],
    });
  });
}
