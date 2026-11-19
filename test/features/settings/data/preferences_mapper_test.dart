import 'package:ctrlspend/core/period/period.dart';
import 'package:ctrlspend/features/settings/data/preferences_mapper.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, String> stored(Preferences prefs) => {
  for (final MapEntry(:key, :value) in preferencesToValues(prefs).entries)
    key: ?value,
};

void main() {
  test('an empty table gives the first-launch defaults', () {
    final prefs = preferencesFromValues({});
    expect(prefs, const Preferences());
    expect(prefs.currencyCode, 'MYR');
    expect(prefs.monthStartDay, const DayOfMonth(1));
    expect(prefs.monthlyBudgetMinor, isNull);
    expect(prefs.theme, AppTheme.system);
    expect(prefs.dailyReminderOn, isTrue);
    expect(prefs.dailyReminderMinutes, 21 * 60);
    expect(prefs.budgetAlertsOn, isTrue);
    expect(prefs.weeklySummaryOn, isFalse);
    expect(prefs.onboardingComplete, isFalse);
  });

  test('every setting survives a round trip', () {
    const prefs = Preferences(
      userName: 'Alex',
      monthStartDay: DayOfMonth(15),
      monthlyBudgetMinor: 200000,
      theme: AppTheme.dark,
      dailyReminderOn: false,
      dailyReminderMinutes: 20 * 60 + 30,
      budgetAlertsOn: false,
      weeklySummaryOn: true,
      billRemindersOn: false,
      onboardingComplete: true,
      appLockOn: true,
      biometricsOn: true,
      lockAfterMinutes: 15,
      hideInSwitcher: true,
      failedPinCount: 7,
    );
    expect(preferencesFromValues(stored(prefs)), prefs);
  });

  test('a currency that is not offered reads as MYR', () {
    for (final code in ['SGD', 'USD', 'XYZ', '']) {
      expect(
        preferencesFromValues({'currencyCode': code}).currencyCode,
        'MYR',
        reason: code,
      );
    }
  });

  test('a lockout ends at a UTC instant', () {
    final until = DateTime(2026, 11, 4, 9, 30, 30);
    final prefs = preferencesFromValues(
      stored(Preferences(lockoutUntil: until)),
    );
    expect(prefs.lockoutUntil, until.toUtc());
  });

  test('the last notification check is stored as a UTC instant', () {
    final at = DateTime(2026, 11, 4, 9, 30);
    final prefs = preferencesFromValues(
      stored(Preferences(notificationsCheckedAt: at)),
    );
    expect(prefs.notificationsCheckedAt, at.toUtc());
    expect(prefs.notificationsCheckedAt!.isAtSameMomentAs(at), isTrue);
    expect(
      preferencesFromValues({'notificationsCheckedAt': 'soon'})
          .notificationsCheckedAt,
      isNull,
    );
  });

  test('a start day read back equals a newly built one', () {
    final prefs = preferencesFromValues({'monthStartDay': '15'});
    expect(prefs, const Preferences(monthStartDay: DayOfMonth(15)));
  });

  test('the last day of the month is stored as "last"', () {
    const prefs = Preferences(monthStartDay: LastDayOfMonth());
    expect(preferencesToValues(prefs)['monthStartDay'], 'last');
    expect(preferencesFromValues(stored(prefs)), prefs);
  });

  test('no overall budget removes the key', () {
    final values = preferencesToValues(const Preferences());
    expect(values.containsKey('monthlyBudgetMinor'), isTrue);
    expect(values['monthlyBudgetMinor'], isNull);
  });

  test('unreadable values fall back to their defaults', () {
    final prefs = preferencesFromValues({
      'monthStartDay': '31',
      'monthlyBudgetMinor': '-5',
      'theme': 'sepia',
      'dailyReminderOn': 'yes',
      'dailyReminderMinutes': '1440',
      'onboardingComplete': '',
      'lockAfterMinutes': '2',
      'failedPinCount': '-1',
      'lockoutUntil': 'soon',
    });
    expect(prefs, const Preferences());
  });

  test('start day 0 and non-numbers fall back to the 1st', () {
    for (final value in ['0', 'abc', '15th']) {
      expect(
        preferencesFromValues({'monthStartDay': value}).monthStartDay,
        const DayOfMonth(1),
        reason: value,
      );
    }
  });
}
