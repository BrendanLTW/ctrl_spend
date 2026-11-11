import 'package:ctrl_spend/features/activity/domain/day_groups.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 1;

Transaction tx(
  int amountMinor,
  DateTime local, {
  TransactionType type = TransactionType.expense,
}) => Transaction(
  id: _nextId++,
  amountMinor: amountMinor,
  type: type,
  categoryId: 1,
  occurredAt: local.toUtc(),
  title: 'x',
);

void main() {
  test('groups by local day, newest first, with the net', () {
    final groups = groupByDay([
      tx(1250, DateTime(2026, 11, 4, 8)),
      tx(480000, DateTime(2026, 11, 3, 10), type: TransactionType.income),
      tx(1820, DateTime(2026, 11, 4, 12)),
      tx(3600, DateTime(2026, 11, 3, 18)),
      tx(13900, DateTime(2026, 11, 1, 9)),
    ]);
    expect(
      [for (final g in groups) g.day],
      [DateTime(2026, 11, 4), DateTime(2026, 11, 3), DateTime(2026, 11)],
    );
    expect([for (final g in groups) g.netMinor], [-3070, 476400, -13900]);
    expect(
      [for (final t in groups.first.transactions) t.amountMinor],
      [1820, 1250],
    );
  });

  test('either side of local midnight are different days', () {
    final groups = groupByDay([
      tx(100, DateTime(2026, 11, 3, 23, 59, 59)),
      tx(200, DateTime(2026, 11, 4)),
    ]);
    expect(groups, hasLength(2));
    expect(groups.first.day, DateTime(2026, 11, 4));
  });

  test('equal times keep the newest entry first', () {
    final at = DateTime(2026, 11, 4, 9);
    final first = tx(100, at);
    final second = tx(200, at);
    expect(groupByDay([first, second]).single.transactions, [second, first]);
  });

  test('no transactions, no groups', () {
    expect(groupByDay([]), isEmpty);
  });
}
