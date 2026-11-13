import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/domain/bill_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Bill bill(
    String name, {
    required DateTime due,
    BillRepeat repeat = const BillRepeat(unit: RepeatUnit.week),
    int amountMinor = 1000,
  }) => Bill(
    id: name.hashCode,
    name: name,
    amountMinor: amountMinor,
    categoryId: 4,
    repeat: repeat,
    nextDue: due,
    iconKey: CategoryIconKey.bolt,
    colorKey: CategoryColorKey.yellow,
  );

  group('nextDue', () {
    test('days and weeks count calendar days', () {
      const tenDays = BillRepeat(unit: RepeatUnit.day, every: 10);
      const weekly = BillRepeat(unit: RepeatUnit.week);
      const fortnightly = BillRepeat(unit: RepeatUnit.week, every: 2);
      expect(nextDue(DateTime(2026, 11, 8), tenDays), DateTime(2026, 11, 18));
      expect(nextDue(DateTime(2026, 11, 8), weekly), DateTime(2026, 11, 15));
      expect(
        nextDue(DateTime(2026, 11, 8), fortnightly),
        DateTime(2026, 11, 22),
      );
      expect(nextDue(DateTime(2026, 12, 29), weekly), DateTime(2027, 1, 5));
    });

    test('daily steps stay on local midnight for a year', () {
      const daily = BillRepeat(unit: RepeatUnit.day);
      var due = DateTime(2026);
      for (var i = 0; i < 365; i++) {
        due = nextDue(due, daily);
        expect((due.hour, due.minute), (0, 0), reason: '$due');
      }
      expect(due, DateTime(2027));
    });

    test('a monthly bill returns to its day after a shorter month', () {
      const on31st = BillRepeat(unit: RepeatUnit.month, day: 31);
      final feb = nextDue(DateTime(2027, 1, 31), on31st);
      expect(feb, DateTime(2027, 2, 28));
      expect(nextDue(feb, on31st), DateTime(2027, 3, 31));
      expect(nextDue(DateTime(2028, 1, 31), on31st), DateTime(2028, 2, 29));
    });

    test('months cross the year end, every 1 or 3', () {
      const monthly = BillRepeat(unit: RepeatUnit.month, day: 15);
      const quarterly = BillRepeat(unit: RepeatUnit.month, every: 3, day: 8);
      expect(nextDue(DateTime(2026, 12, 15), monthly), DateTime(2027, 1, 15));
      expect(nextDue(DateTime(2026, 11, 8), quarterly), DateTime(2027, 2, 8));
    });

    test('a yearly bill on 29 Feb falls back, then returns in a leap year', () {
      const yearly = BillRepeat(unit: RepeatUnit.year, day: 29);
      var due = DateTime(2028, 2, 29);
      final dues = [for (var i = 0; i < 4; i++) due = nextDue(due, yearly)];
      expect(dues, [
        DateTime(2029, 2, 28),
        DateTime(2030, 2, 28),
        DateTime(2031, 2, 28),
        DateTime(2032, 2, 29),
      ]);
    });
  });

  group('paymentsDue', () {
    final period = (start: DateTime(2026, 10, 15), end: DateTime(2026, 11, 14));

    test('lists each payment due by the period end, soonest first', () {
      final gym = bill('Gym', due: DateTime(2026, 11, 5));
      final unifi = bill(
        'Unifi',
        due: DateTime(2026, 11, 8),
        repeat: const BillRepeat(unit: RepeatUnit.month, day: 8),
      );
      final rent = bill(
        'Rent',
        due: DateTime(2026, 11, 20),
        repeat: const BillRepeat(unit: RepeatUnit.month, day: 20),
      );
      expect(
        [
          for (final p in paymentsDue([rent, unifi, gym], period))
            (p.bill.name, p.due),
        ],
        [
          ('Gym', DateTime(2026, 11, 5)),
          ('Unifi', DateTime(2026, 11, 8)),
          ('Gym', DateTime(2026, 11, 12)),
        ],
      );
    });

    test('overdue payments and one due on the last day count', () {
      final late = bill('Late', due: DateTime(2026, 10, 2));
      final lastDay = bill(
        'Last day',
        due: DateTime(2026, 11, 14),
        repeat: const BillRepeat(unit: RepeatUnit.month, day: 14),
      );
      final dues = paymentsDue([late, lastDay], period);
      expect(dues.where((p) => p.bill == late), hasLength(7));
      expect(dues.last, (bill: lastDay, due: DateTime(2026, 11, 14)));
    });

    test('no bills, no payments', () {
      expect(paymentsDue(const [], period), isEmpty);
    });
  });

  group('leftAfterBills', () {
    final due = [
      (
        bill: bill('Unifi', due: DateTime(2026, 11, 8), amountMinor: 12900),
        due: DateTime(2026, 11, 8),
      ),
      (
        bill: bill('Gym', due: DateTime(2026, 11, 5), amountMinor: 5000),
        due: DateTime(2026, 11, 5),
      ),
    ];

    test('is left to spend minus the payments due', () {
      expect(
        leftAfterBills(budgetMinor: 200000, spentMinor: 80000, due: due),
        102100,
      );
    });

    test('can go below zero', () {
      expect(
        leftAfterBills(budgetMinor: 20000, spentMinor: 10000, due: due),
        -7900,
      );
    });

    test('is null without a monthly budget', () {
      expect(
        leftAfterBills(budgetMinor: null, spentMinor: 80000, due: due),
        isNull,
      );
    });
  });
}
