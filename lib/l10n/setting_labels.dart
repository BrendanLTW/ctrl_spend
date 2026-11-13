import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

extension SettingLabels on AppLocalizations {
  /// "15th" or "Last day" (S08, S21).
  String startDayLabel(MonthStartDay startDay) => switch (startDay) {
    DayOfMonth(:final day) => ordinalDay('$day'),
    LastDayOfMonth() => lastDay,
  };

  /// A reminder time stored as minutes after midnight, in the locale's
  /// format: "9:00 PM".
  String reminderTime(int minutes, String locale) =>
      DateFormat.jm(locale)
          .format(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));
}
