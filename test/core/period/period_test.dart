import 'package:ctrl_spend/core/period/period.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

void expectPeriod(
  DateTime date,
  MonthStartDay startDay,
  DateTime start,
  DateTime end,
) {
  expect(periodFor(date, startDay), (start: start, end: end), reason: '$date');
}

void main() {
  group('start day 1 (calendar months)', () {
    const s = DayOfMonth(1);

    test('31-day month', () {
      expectPeriod(d(2026, 10, 1), s, d(2026, 10, 1), d(2026, 10, 31));
      expectPeriod(d(2026, 10, 31), s, d(2026, 10, 1), d(2026, 10, 31));
    });

    test('30-day month', () {
      expectPeriod(d(2026, 11, 15), s, d(2026, 11, 1), d(2026, 11, 30));
    });

    test('February in a non-leap and a leap year', () {
      expectPeriod(d(2026, 2, 10), s, d(2026, 2, 1), d(2026, 2, 28));
      expectPeriod(d(2028, 2, 29), s, d(2028, 2, 1), d(2028, 2, 29));
    });
  });

  group('start day 15', () {
    const s = DayOfMonth(15);

    test('runs to the 14th of the next month', () {
      expectPeriod(d(2026, 10, 20), s, d(2026, 10, 15), d(2026, 11, 14));
    });

    test('boundaries: the 15th starts, the 14th ends', () {
      expectPeriod(d(2026, 10, 15), s, d(2026, 10, 15), d(2026, 11, 14));
      expectPeriod(d(2026, 11, 14), s, d(2026, 10, 15), d(2026, 11, 14));
      expectPeriod(d(2026, 10, 14), s, d(2026, 9, 15), d(2026, 10, 14));
    });

    test('crosses the year end', () {
      expectPeriod(d(2026, 12, 31), s, d(2026, 12, 15), d(2027, 1, 14));
      expectPeriod(d(2027, 1, 3), s, d(2026, 12, 15), d(2027, 1, 14));
    });

    test('spans February in non-leap and leap years', () {
      final nonLeap = periodFor(d(2026, 2, 20), s);
      expect(nonLeap, (start: d(2026, 2, 15), end: d(2026, 3, 14)));
      expect(nonLeap.days, 28);
      final leap = periodFor(d(2028, 2, 20), s);
      expect(leap, (start: d(2028, 2, 15), end: d(2028, 3, 14)));
      expect(leap.days, 29);
    });
  });

  group('start day 28', () {
    const s = DayOfMonth(28);

    test('runs to the 27th of the next month', () {
      expectPeriod(d(2026, 10, 28), s, d(2026, 10, 28), d(2026, 11, 27));
      expectPeriod(d(2026, 10, 27), s, d(2026, 9, 28), d(2026, 10, 27));
    });

    test('February 28 starts a period in a non-leap year', () {
      expectPeriod(d(2026, 2, 28), s, d(2026, 2, 28), d(2026, 3, 27));
    });

    test('February 29 in a leap year belongs to the period from the 28th', () {
      expectPeriod(d(2028, 2, 29), s, d(2028, 2, 28), d(2028, 3, 27));
    });

    test('the 29th–31st belong to the period from the 28th', () {
      expectPeriod(d(2026, 1, 31), s, d(2026, 1, 28), d(2026, 2, 27));
      expectPeriod(d(2026, 3, 30), s, d(2026, 3, 28), d(2026, 4, 27));
    });

    test('crosses the year end', () {
      expectPeriod(d(2027, 1, 2), s, d(2026, 12, 28), d(2027, 1, 27));
    });
  });

  group('last day of the month', () {
    const s = LastDayOfMonth();

    test('31-day month to the day before the next last day', () {
      expectPeriod(d(2026, 10, 31), s, d(2026, 10, 31), d(2026, 11, 29));
      expectPeriod(d(2026, 11, 29), s, d(2026, 10, 31), d(2026, 11, 29));
    });

    test('30-day month', () {
      expectPeriod(d(2026, 11, 30), s, d(2026, 11, 30), d(2026, 12, 30));
      expectPeriod(d(2026, 12, 30), s, d(2026, 11, 30), d(2026, 12, 30));
    });

    test('31 Jan runs to 27 Feb in a non-leap year, 28 Feb in a leap year', () {
      expectPeriod(d(2026, 2, 27), s, d(2026, 1, 31), d(2026, 2, 27));
      expectPeriod(d(2028, 2, 28), s, d(2028, 1, 31), d(2028, 2, 28));
    });

    test('February starts on the 28th, or the 29th in a leap year', () {
      expectPeriod(d(2026, 2, 28), s, d(2026, 2, 28), d(2026, 3, 30));
      expectPeriod(d(2028, 2, 29), s, d(2028, 2, 29), d(2028, 3, 30));
    });

    test('a day mid-month belongs to the period from last month', () {
      expectPeriod(d(2026, 3, 15), s, d(2026, 2, 28), d(2026, 3, 30));
    });

    test('crosses the year end', () {
      expectPeriod(d(2026, 12, 31), s, d(2026, 12, 31), d(2027, 1, 30));
      expectPeriod(d(2027, 1, 30), s, d(2026, 12, 31), d(2027, 1, 30));
    });
  });

  test('every day of four years falls in exactly one period, with no gaps', () {
    for (final s in [
      const DayOfMonth(1),
      const DayOfMonth(15),
      const DayOfMonth(28),
      const LastDayOfMonth(),
    ]) {
      var period = periodFor(d(2025, 1, 1), s);
      for (var i = 0; i < 4 * 366; i++) {
        final day = d(2025, 1, 1 + i);
        if (!period.contains(day)) {
          final next = periodFor(day, s);
          expect(next.start, day, reason: 'gap before $day');
          period = next;
        }
        expect(periodFor(day, s), period, reason: '$day');
        expect(period.days, inInclusiveRange(28, 31));
      }
    }
  });

  group('time of day and time zones', () {
    test('the time of day is ignored', () {
      expect(
        periodFor(DateTime(2026, 11, 14, 23, 59, 59), const DayOfMonth(15)),
        (start: d(2026, 10, 15), end: d(2026, 11, 14)),
      );
    });

    test('a UTC date uses its local calendar day', () {
      final utc = DateTime.utc(2026, 11, 14, 23, 30);
      final local = utc.toLocal();
      expect(
        periodFor(utc, const DayOfMonth(15)),
        periodFor(d(local.year, local.month, local.day), const DayOfMonth(15)),
      );
    });
  });

  group('Period', () {
    final p = (start: d(2026, 10, 15), end: d(2026, 11, 14));

    test('days counts both ends', () {
      expect(p.days, 31);
    });

    test('contains its first and last day, at any time', () {
      expect(p.contains(DateTime(2026, 10, 15)), isTrue);
      expect(p.contains(DateTime(2026, 11, 14, 23, 59)), isTrue);
      expect(p.contains(DateTime(2026, 10, 14, 23, 59)), isFalse);
      expect(p.contains(DateTime(2026, 11, 15)), isFalse);
    });
  });

  group('daysLeft', () {
    final p = (start: d(2026, 10, 15), end: d(2026, 11, 14));

    test('does not count today', () {
      expect(daysLeft(p, DateTime(2026, 11, 4, 9)), 10);
      expect(daysLeft(p, d(2026, 10, 15)), 30);
    });

    test('is 0 on the last day and 1 the day before', () {
      expect(daysLeft(p, DateTime(2026, 11, 14, 23, 59)), 0);
      expect(daysLeft(p, d(2026, 11, 13)), 1);
    });

    test('crosses a year end', () {
      final dec = periodFor(d(2026, 12, 20), const DayOfMonth(15));
      expect(daysLeft(dec, d(2026, 12, 31)), 14);
    });
  });
}
