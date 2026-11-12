import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';

/// Keys in the Preferences table (PRD §8).
abstract final class PreferenceKeys {
  static const userName = 'userName';
  static const currencyCode = 'currencyCode';
  static const monthStartDay = 'monthStartDay';
  static const monthlyBudgetMinor = 'monthlyBudgetMinor';
  static const theme = 'theme';
  static const dailyReminderOn = 'dailyReminderOn';
  static const dailyReminderMinutes = 'dailyReminderMinutes';
  static const budgetAlertsOn = 'budgetAlertsOn';
  static const weeklySummaryOn = 'weeklySummaryOn';
  static const onboardingComplete = 'onboardingComplete';
  static const notificationsCheckedAt = 'notificationsCheckedAt';
}

/// Builds [Preferences] from the table's key-value pairs. A missing or
/// unreadable value falls back to its default, so a bad row never stops
/// the app from starting.
Preferences preferencesFromValues(Map<String, String> values) {
  const defaults = Preferences();
  int? integer(String key) => int.tryParse(values[key] ?? '');
  bool? flag(String key) => bool.tryParse(values[key] ?? '');
  return Preferences(
    userName: values[PreferenceKeys.userName] ?? defaults.userName,
    currencyCode: values[PreferenceKeys.currencyCode] ?? defaults.currencyCode,
    monthStartDay:
        _parseStartDay(values[PreferenceKeys.monthStartDay]) ??
        defaults.monthStartDay,
    monthlyBudgetMinor: switch (integer(PreferenceKeys.monthlyBudgetMinor)) {
      final minor? when minor >= 0 => minor,
      _ => null,
    },
    theme:
        AppTheme.values.asNameMap()[values[PreferenceKeys.theme]] ??
        defaults.theme,
    dailyReminderOn:
        flag(PreferenceKeys.dailyReminderOn) ?? defaults.dailyReminderOn,
    dailyReminderMinutes: switch (integer(
      PreferenceKeys.dailyReminderMinutes,
    )) {
      final minutes? when minutes >= 0 && minutes < 24 * 60 => minutes,
      _ => defaults.dailyReminderMinutes,
    },
    budgetAlertsOn:
        flag(PreferenceKeys.budgetAlertsOn) ?? defaults.budgetAlertsOn,
    weeklySummaryOn:
        flag(PreferenceKeys.weeklySummaryOn) ?? defaults.weeklySummaryOn,
    onboardingComplete:
        flag(PreferenceKeys.onboardingComplete) ?? defaults.onboardingComplete,
    notificationsCheckedAt: DateTime.tryParse(
      values[PreferenceKeys.notificationsCheckedAt] ?? '',
    ),
  );
}

/// The table's key-value pairs for [prefs]. A null value means the key
/// should be removed (no overall budget).
Map<String, String?> preferencesToValues(Preferences prefs) => {
  PreferenceKeys.userName: prefs.userName,
  PreferenceKeys.currencyCode: prefs.currencyCode,
  PreferenceKeys.monthStartDay: switch (prefs.monthStartDay) {
    DayOfMonth(:final day) => '$day',
    LastDayOfMonth() => 'last',
  },
  PreferenceKeys.monthlyBudgetMinor: prefs.monthlyBudgetMinor?.toString(),
  PreferenceKeys.theme: prefs.theme.name,
  PreferenceKeys.dailyReminderOn: '${prefs.dailyReminderOn}',
  PreferenceKeys.dailyReminderMinutes: '${prefs.dailyReminderMinutes}',
  PreferenceKeys.budgetAlertsOn: '${prefs.budgetAlertsOn}',
  PreferenceKeys.weeklySummaryOn: '${prefs.weeklySummaryOn}',
  PreferenceKeys.onboardingComplete: '${prefs.onboardingComplete}',
  PreferenceKeys.notificationsCheckedAt: prefs.notificationsCheckedAt
      ?.toUtc()
      .toIso8601String(),
};

MonthStartDay? _parseStartDay(String? value) {
  if (value == 'last') return const LastDayOfMonth();
  return switch (int.tryParse(value ?? '')) {
    final day? when day >= 1 && day <= 28 => DayOfMonth(day),
    _ => null,
  };
}
