import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// One day of Activity (S16): its local date, net total (income − spent)
/// and transactions, newest first.
typedef DayGroup = ({
  DateTime day,
  int netMinor,
  List<Transaction> transactions,
});

/// Groups [transactions] by local calendar day, newest day first.
List<DayGroup> groupByDay(Iterable<Transaction> transactions) {
  final sorted = transactions.toList()
    ..sort((a, b) {
      final byTime = b.occurredAt.compareTo(a.occurredAt);
      return byTime != 0 ? byTime : b.id - a.id;
    });
  final groups = <DayGroup>[];
  for (final t in sorted) {
    final at = t.occurredAt.toLocal();
    final day = DateTime(at.year, at.month, at.day);
    final signed = t.type == TransactionType.income
        ? t.amountMinor
        : -t.amountMinor;
    if (groups.isNotEmpty && groups.last.day == day) {
      final last = groups.removeLast();
      groups.add((
        day: day,
        netMinor: last.netMinor + signed,
        transactions: [...last.transactions, t],
      ));
    } else {
      groups.add((day: day, netMinor: signed, transactions: [t]));
    }
  }
  return groups;
}
