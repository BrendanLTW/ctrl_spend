import 'package:ctrl_spend/core/period/period.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';

/// S68's Lock after choices, in minutes.
const lockAfterChoices = [0, 1, 5, 15, 60];

/// The Theme setting (S33). Flutter's `ThemeMode` isn't pure Dart.
enum AppTheme { light, dark, system }

/// The user's settings (PRD §8 Preferences), with first-launch defaults.
@freezed
abstract class Preferences with _$Preferences {
  const factory({
    @Default('') String userName,
    @Default('MYR') String currencyCode,
    @Default(DayOfMonth(1)) MonthStartDay monthStartDay,

    /// Null means no overall budget.
    int? monthlyBudgetMinor,
    @Default(AppTheme.system) AppTheme theme,
    @Default(true) bool dailyReminderOn,

    /// Minutes after local midnight; 21:00 by default (S07).
    @Default(21 * 60) int dailyReminderMinutes,
    @Default(true) bool budgetAlertsOn,
    @Default(false) bool weeklySummaryOn,

    /// Bill reminders as a whole (S48); each bill also has its own.
    @Default(true) bool billRemindersOn,
    @Default(false) bool onboardingComplete,

    /// App lock (v1.1, S37). The PIN itself lives in secure storage.
    @Default(false) bool appLockOn,
    @Default(false) bool biometricsOn,

    /// Minutes in the background before the app locks: one of
    /// [lockAfterChoices].
    @Default(0) int lockAfterMinutes,
    @Default(false) bool hideInSwitcher,

    /// Wrong PINs in a row, and when entry may resume after a lockout
    /// (S66).
    @Default(0) int failedPinCount,
    DateTime? lockoutUntil,

    /// When scheduled notifications were last turned into inbox rows (PRD
    /// §5.4). Null until the first check.
    DateTime? notificationsCheckedAt,
  }) = _Preferences;
}
