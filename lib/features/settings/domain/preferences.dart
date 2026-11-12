import 'package:ctrl_spend/core/period/period.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';

/// The Theme setting (S33). Flutter's `ThemeMode` isn't pure Dart.
enum AppTheme { light, dark, system }

/// The user's settings (PRD §8 Preferences), with first-launch defaults.
/// App-lock settings arrive with v1.1.
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
    @Default(false) bool onboardingComplete,

    /// When scheduled notifications were last turned into inbox rows (PRD
    /// §5.4). Null until the first check.
    DateTime? notificationsCheckedAt,
  }) = _Preferences;
}
