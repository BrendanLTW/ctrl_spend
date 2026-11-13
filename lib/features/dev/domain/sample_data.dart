import 'dart:math';

import 'package:ctrl_spend/features/categories/domain/default_categories.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';

/// Sample titles per default category, for [sampleTransactions].
const _titles = {
  'Food': [
    'Nasi lemak',
    'Teh tarik',
    'Roti canai',
    'Mamak dinner',
    'Groceries',
  ],
  'Transport': ['Grab to KLCC', 'LRT top-up', 'Petrol', 'Parking'],
  'Shopping': ['Uniqlo', 'Shopee order', 'Mr DIY', 'Watsons'],
  'Bills': ['TNB electricity', 'Unifi', 'Water bill', 'Phone plan'],
  'Fun': ['Cinema', 'Netflix', 'Bowling', 'Concert ticket'],
  'Health': ['Clinic visit', 'Pharmacy', 'Gym pass'],
  'Salary': ['Monthly salary'],
  'Gifts': ['Birthday gift', 'Ang pao'],
};

/// [count] made-up transactions over the [months] before [today], newest
/// last, in the default categories, for measuring the app with a large
/// history (task 4.3). The same [seed] gives the same data. About one in
/// 30 is income and one in eight has a note.
List<ImportedTransaction> sampleTransactions({
  required DateTime today,
  int count = 5000,
  int months = 12,
  int seed = 42,
}) {
  final random = Random(seed);
  final expense = [
    for (final c in defaultCategories)
      if (c.type == TransactionType.expense) c.name,
  ];
  final income = [
    for (final c in defaultCategories)
      if (c.type == TransactionType.income) c.name,
  ];
  final start = DateTime(today.year, today.month - months, today.day);
  final span = today.difference(start).inMinutes;
  final rows = <ImportedTransaction>[
    for (var i = 0; i < count; i++)
      () {
        final isIncome = random.nextInt(30) == 0;
        final names = isIncome ? income : expense;
        final category = names[random.nextInt(names.length)];
        final titles = _titles[category]!;
        return (
          occurredAt: start.add(Duration(minutes: random.nextInt(span))),
          type: isIncome ? TransactionType.income : TransactionType.expense,
          category: category,
          title: titles[random.nextInt(titles.length)],
          amountMinor: isIncome
              ? 50000 + random.nextInt(450000)
              : 300 + random.nextInt(15000),
          note: random.nextInt(8) == 0 ? 'Sample note' : null,
        );
      }(),
  ]..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  return rows;
}
