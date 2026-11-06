import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/periods/domain/period_summary.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

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
  occurredAt: (at ?? DateTime(2026, 11, 2, 12)).toUtc(),
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
  final period = (start: DateTime(2026, 10, 15), end: DateTime(2026, 11, 14));
  final categories = [
    category(1, limitMinor: 40000), // Food
    category(2), // Transport, no limit
    category(3, limitMinor: 20000), // Shopping, limit, no spend
    category(4), // no limit, no spend
    category(5, limitMinor: 10000, archived: true), // archived, no spend
    category(6, archived: true), // archived, with spend
    category(7, type: TransactionType.income), // Salary
  ];
  final transactions = [
    tx(51200),
    tx(3000, categoryId: 2),
    tx(800, categoryId: 6),
    tx(250000, categoryId: 7, type: TransactionType.income),
    tx(9999, at: DateTime(2026, 10, 14, 23)),
  ];

  PeriodSummary summary({int? budgetMinor = 200000}) => periodSummary(
    transactions,
    period: period,
    categories: categories,
    budgetMinor: budgetMinor,
  );

  test('totals the period against the budget', () {
    final s = summary();
    expect(s.period, period);
    expect(s.spentMinor, 55000);
    expect(s.leftMinor, 145000, reason: 'RM 1,450 under');
  });

  test('a period over budget has a negative left', () {
    final s = periodSummary(
      transactions,
      period: period,
      categories: categories,
      budgetMinor: 54000,
    );
    expect(s.leftMinor, -1000, reason: 'Over by RM 10');
  });

  test('without a budget there is no over/under', () {
    expect(summary(budgetMinor: null).leftMinor, isNull);
  });

  test('lists categories that spent or have a limit, by spend', () {
    expect([for (final c in summary().categories) c.categoryId], [1, 2, 6, 3]);
  });

  test('each category shows its result against its limit', () {
    final byId = {for (final c in summary().categories) c.categoryId: c};
    expect(byId[1]!.spentMinor, 51200);
    expect(byId[1]!.leftMinor, -11200, reason: 'RM 112 over · limit RM 400');
    expect(byId[2]!.leftMinor, isNull, reason: 'No limit');
    expect(byId[3]!.spentMinor, 0);
    expect(byId[3]!.leftMinor, 20000);
  });
}
