import 'package:ctrlspend/core/money/money_formatter.dart';
import 'package:ctrlspend/core/period/period.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';

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
  static const billRemindersOn = 'billRemindersOn';
  static const appLockOn = 'appLockOn';
  static const biometricsOn = 'biometricsOn';
  static const lockAfterMinutes = 'lockAfterMinutes';
  static const hideInSwitcher = 'hideInSwitcher';
  static const failedPinCount = 'failedPinCount';
  static const lockoutUntil = 'lockoutUntil';
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
    // Only offered currencies (MYR for now) are read back.
    currencyCode: switch (values[PreferenceKeys.currencyCode]) {
      final code? when offeredCurrencies.any((c) => c.code == code) => code,
      _ => defaults.currencyCode,
    },
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
    billRemindersOn:
        flag(PreferenceKeys.billRemindersOn) ?? defaults.billRemindersOn,
    appLockOn: flag(PreferenceKeys.appLockOn) ?? defaults.appLockOn,
    biometricsOn: flag(PreferenceKeys.biometricsOn) ?? defaults.biometricsOn,
    lockAfterMinutes: switch (integer(PreferenceKeys.lockAfterMinutes)) {
      final minutes? when lockAfterChoices.contains(minutes) => minutes,
      _ => defaults.lockAfterMinutes,
    },
    hideInSwitcher:
        flag(PreferenceKeys.hideInSwitcher) ?? defaults.hideInSwitcher,
    failedPinCount: switch (integer(PreferenceKeys.failedPinCount)) {
      final count? when count >= 0 => count,
      _ => defaults.failedPinCount,
    },
    lockoutUntil: DateTime.tryParse(values[PreferenceKeys.lockoutUntil] ?? ''),
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
  PreferenceKeys.billRemindersOn: '${prefs.billRemindersOn}',
  PreferenceKeys.appLockOn: '${prefs.appLockOn}',
  PreferenceKeys.biometricsOn: '${prefs.biometricsOn}',
  PreferenceKeys.lockAfterMinutes: '${prefs.lockAfterMinutes}',
  PreferenceKeys.hideInSwitcher: '${prefs.hideInSwitcher}',
  PreferenceKeys.failedPinCount: '${prefs.failedPinCount}',
  PreferenceKeys.lockoutUntil: prefs.lockoutUntil?.toUtc().toIso8601String(),
};

MonthStartDay? _parseStartDay(String? value) {
  if (value == 'last') return const LastDayOfMonth();
  return switch (int.tryParse(value ?? '')) {
    final day? when day >= 1 && day <= 28 => DayOfMonth(day),
    _ => null,
  };
}
