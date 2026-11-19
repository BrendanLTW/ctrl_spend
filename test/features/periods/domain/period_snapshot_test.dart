import 'package:ctrlspend/core/period/period.dart';
import 'package:ctrlspend/features/categories/domain/category.dart';
import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/features/periods/domain/period_snapshot.dart';
import 'package:ctrlspend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

/// 4 Nov 2026; with start day 15 the current period is 15 Oct – 14 Nov.
final today = DateTime(2026, 11, 4, 9);
const startDay = DayOfMonth(15);

var _id = 1;
Transaction tx(int minor, DateTime at, {bool income = false}) => Transaction(
  id: _id++,
  amountMinor: minor,
  type: income ? TransactionType.income : TransactionType.expense,
  categoryId: income ? 7 : 1,
  occurredAt: at.toUtc(),
  title: 'x',
);

Category category(int id, TransactionType type, {int? limit}) => Category(
  id: id,
  name: 'c$id',
  type: type,
  iconKey: CategoryIconKey.food,
  colorKey: CategoryColorKey.orange,
  sortOrder: id,
  limitMinor: limit,
);

void main() {
  final history = [
    tx(10000, DateTime(2026, 8, 20)),
    tx(480000, DateTime(2026, 9, 16), income: true),
    tx(30000, DateTime(2026, 9, 20)),
    tx(5000, DateTime(2026, 11, 2)),
  ];
  final categories = [
    category(1, TransactionType.expense, limit: 40000),
    category(2, TransactionType.expense),
    category(7, TransactionType.income),
  ];

  List<PeriodSnapshot> due(
    Iterable<PeriodSnapshot> existing, {
    MonthStartDay start = startDay,
    int? budget = 200000,
  }) => snapshotsToWrite(
    existing: existing,
    transactions: history,
    categories: categories,
    today: today,
    startDay: start,
    budgetMinor: budget,
  );

  test('backfills every ended period since the first transaction', () {
    final snapshots = due(const []);
    expect(
      [for (final s in snapshots) s.period.start],
      [DateTime(2026, 8, 15), DateTime(2026, 9, 15)],
    );
    final september = snapshots.last;
    expect(september.period.end, DateTime(2026, 10, 14));
    expect((september.spentMinor, september.incomeMinor), (30000, 480000));
    expect(september.budgetMinor, 200000);
    expect(september.limits, {1: 40000});
  });

  test('the current period is never saved', () {
    expect(
      due(const []).where((s) => s.period.start == DateTime(2026, 10, 15)),
      isEmpty,
    );
  });

  test('only periods ending after the latest snapshot', () {
    final first = due(const []).first;
    expect(
      [
        for (final s in due([first])) s.period.start,
      ],
      [DateTime(2026, 9, 15)],
    );
    expect(due(due(const [])), isEmpty);
  });

  test('a month-start change neither rewrites nor doubles old ones', () {
    final saved = due(const []);
    // Now the 1st: the period 1 Oct – 31 Oct ends after 14 Oct, so it's
    // saved; 1 Sep – 30 Sep isn't, being covered already.
    expect(
      [for (final s in due(saved, start: const DayOfMonth(1))) s.period],
      [(start: DateTime(2026, 10), end: DateTime(2026, 10, 31))],
    );
  });

  test('no transactions, no snapshots', () {
    expect(
      snapshotsToWrite(
        existing: const [],
        transactions: const [],
        categories: categories,
        today: today,
        startDay: startDay,
        budgetMinor: 200000,
      ),
      isEmpty,
    );
  });

  test('withSnapshotLimits puts back the saved limits', () {
    final snapshot = due(const []).last;
    final now = [
      category(1, TransactionType.expense, limit: 90000),
      category(2, TransactionType.expense, limit: 10000),
    ];
    expect(
      [for (final c in withSnapshotLimits(now, snapshot)) c.limitMinor],
      [40000, null],
    );
  });
}
