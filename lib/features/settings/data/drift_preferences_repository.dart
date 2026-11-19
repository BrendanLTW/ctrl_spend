import 'package:ctrlspend/core/db/app_database.dart';
import 'package:ctrlspend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrlspend/features/categories/data/category_mapper.dart';
import 'package:ctrlspend/features/settings/data/preferences_mapper.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';

class DriftPreferencesRepository implements PreferencesRepository {
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<Preferences> watch() =>
      _db.select(_db.preferences).watch().map(_fromRows);

  @override
  Future<Preferences> read() async =>
      _fromRows(await _db.select(_db.preferences).get());

  @override
  Future<void> update(Preferences Function(Preferences) change) =>
      _db.transaction(() async {
        final before = await read();
        final after = change(before);
        // The budget can't drop below the category limits (PRD §5.6).
        // Removing it is fine: the limits stay.
        final budget = after.monthlyBudgetMinor;
        if (budget != null && budget != before.monthlyBudgetMinor) {
          final limits = allocated([
            for (final row in await _db.select(_db.categories).get())
              row.toEntity(),
          ]);
          if (limits > budget) throw BudgetBelowLimitsException(limits);
        }
        final values = preferencesToValues(after);
        // Only our keys are touched; others (v1.1 app lock) are left alone.
        for (final MapEntry(:key, :value) in values.entries) {
          if (value == null) {
            await (_db.delete(
              _db.preferences,
            )..where((p) => p.key.equals(key))).go();
          } else {
            await _db
                .into(_db.preferences)
                .insertOnConflictUpdate(
                  PreferencesCompanion.insert(key: key, value: value),
                );
          }
        }
      });

  Preferences _fromRows(List<PreferenceRow> rows) =>
      preferencesFromValues({for (final row in rows) row.key: row.value});
}
