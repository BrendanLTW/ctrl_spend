import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftPreferencesRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftPreferencesRepository(db);
  });
  tearDown(() => db.close());

  Future<Map<String, String>> stored() async => {
    for (final row in await db.select(db.preferences).get()) row.key: row.value,
  };

  test('an empty table reads as the defaults', () async {
    expect(await repo.read(), const Preferences());
    expect(await repo.watch().first, const Preferences());
  });

  test('update saves every setting', () async {
    const all = Preferences(
      userName: 'Alex',
      currencyCode: 'SGD',
      monthStartDay: LastDayOfMonth(),
      monthlyBudgetMinor: 200000,
      theme: AppTheme.dark,
      dailyReminderOn: false,
      dailyReminderMinutes: 20 * 60,
      budgetAlertsOn: false,
      weeklySummaryOn: true,
      onboardingComplete: true,
    );
    await repo.update((_) => all);
    expect(await repo.read(), all);
  });

  test('update changes only what the callback changes', () async {
    await repo.update((p) => p.copyWith(userName: 'Alex'));
    await repo.update((p) => p.copyWith(theme: AppTheme.dark));
    final prefs = await repo.read();
    expect(prefs.userName, 'Alex');
    expect(prefs.theme, AppTheme.dark);
  });

  test('removing the budget deletes its key', () async {
    await repo.update((p) => p.copyWith(monthlyBudgetMinor: 200000));
    expect((await stored())['monthlyBudgetMinor'], '200000');
    await repo.update((p) => p.copyWith(monthlyBudgetMinor: null));
    expect(await stored(), isNot(contains('monthlyBudgetMinor')));
    expect((await repo.read()).monthlyBudgetMinor, isNull);
  });

  test('keys it does not know are left alone', () async {
    await db
        .into(db.preferences)
        .insert(
          PreferencesCompanion.insert(key: 'appLockEnabled', value: 'true'),
        );
    await repo.update((p) => p.copyWith(userName: 'Alex'));
    expect((await stored())['appLockEnabled'], 'true');
  });

  test('concurrent updates both stick', () async {
    await Future.wait([
      repo.update((p) => p.copyWith(userName: 'Alex')),
      repo.update((p) => p.copyWith(weeklySummaryOn: true)),
    ]);
    final prefs = await repo.read();
    expect(prefs.userName, 'Alex');
    expect(prefs.weeklySummaryOn, isTrue);
  });

  test('watch emits the new settings after each update', () async {
    final seen = <Preferences>[];
    final sub = repo.watch().listen(seen.add);
    addTearDown(sub.cancel);

    await pumpEventQueue();
    expect(seen.single, const Preferences());
    await repo.update((p) => p.copyWith(theme: AppTheme.light));
    await pumpEventQueue();
    expect(seen.last.theme, AppTheme.light);
  });
}
