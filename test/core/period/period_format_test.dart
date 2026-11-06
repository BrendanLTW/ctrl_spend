import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // The app's localisation delegates load these; a unit test must.
  setUpAll(() => initializeDateFormatting('en'));

  test('formats a period as day and short month', () {
    final p = periodFor(DateTime(2026, 11, 4), const DayOfMonth(15));
    expect(formatPeriod(p, 'en'), '15 Oct – 14 Nov');
  });

  test('crosses a year end without showing the year', () {
    final p = periodFor(DateTime(2027, 1, 3), const DayOfMonth(28));
    expect(formatPeriod(p, 'en'), '28 Dec – 27 Jan');
  });
}
