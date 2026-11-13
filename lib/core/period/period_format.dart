import 'package:ctrl_spend/core/period/period.dart';
import 'package:intl/intl.dart';

/// "15 Oct – 14 Nov" (S04, S09). The year is left out, as in the designs.
String formatPeriod(Period period, String locale) {
  final format = DateFormat('d MMM', locale);
  return '${format.format(period.start)} – ${format.format(period.end)}';
}
