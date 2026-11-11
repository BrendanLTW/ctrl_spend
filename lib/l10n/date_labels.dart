import 'package:ctrl_spend/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

extension DateLabels on AppLocalizations {
  /// "Today", "Yesterday" or "3 Nov" for [date]'s local day, relative to
  /// [today].
  String dayLabel(DateTime date, DateTime today, String locale) {
    final local = date.toLocal();
    final day = DateTime.utc(local.year, local.month, local.day);
    final now = DateTime.utc(today.year, today.month, today.day);
    return switch (now.difference(day).inDays) {
      0 => this.today,
      1 => yesterday,
      _ => DateFormat('d MMM', locale).format(local),
    };
  }
}
