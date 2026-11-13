import 'package:ctrl_spend/core/db/tables.dart';
import 'package:ctrl_spend/features/categories/domain/default_categories.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    Notifications,
    Preferences,
    Bills,
    Goals,
    GoalContributions,
  ],
)
class AppDatabase extends _$AppDatabase {
  new(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Runs once, when the file is created: first launch. Re-seeding when
    // the table is empty would bring back categories the user deleted.
    onCreate: (m) async {
      await m.createAll();
      await seedDefaultCategories();
    },
    onUpgrade: (m, from, to) async {
      // v2: notifications remember their category (S14 tiles).
      if (from < 2) {
        await m.addColumn(notifications, notifications.categoryId);
      }
      // v3: bills and savings goals (v1.1).
      if (from < 3) {
        await m.createTable(bills);
        await m.createTable(goals);
        await m.createTable(goalContributions);
        await m.addColumn(transactions, transactions.billId);
      }
    },
    // SQLite ignores foreign keys unless asked, per connection.
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}

extension DefaultCategorySeed on AppDatabase {
  /// Adds the 8 default categories (PRD §8): on first launch, and again
  /// after Delete all data.
  Future<void> seedDefaultCategories() => batch(
    (b) => b.insertAll(categories, [
      for (final (i, c) in defaultCategories.indexed)
        CategoriesCompanion.insert(
          name: c.name,
          type: c.type.name,
          iconKey: c.icon.name,
          colorKey: c.colour.name,
          sortOrder: i,
        ),
    ]),
  );
}

/// The app's database. Tests override this with
/// `AppDatabase(NativeDatabase.memory())`.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(driftDatabase(name: 'ctrl_spend'));
  ref.onDispose(db.close);
  return db;
}
