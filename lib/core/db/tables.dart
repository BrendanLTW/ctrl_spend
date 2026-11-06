// Drift check() constraints name their own column, which this lint flags.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

// Row classes end in `Row` so they don't clash with the domain entities.

/// Expense or income categories (PRD §8).
@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text().check(type.isIn(const ['expense', 'income']))();
  TextColumn get iconKey => text()();
  TextColumn get colorKey => text()();
  IntColumn get limitMinor =>
      integer().nullable().check(limitMinor.isBiggerOrEqualValue(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();

  // Unique per type, ignoring case: "Food" and "food" clash.
  @override
  List<String> get customConstraints => ['UNIQUE (name COLLATE NOCASE, type)'];
}

/// Expenses and income (PRD §8). `occurredAt` is stored in UTC.
@DataClassName('TransactionRow')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountMinor =>
      integer().check(amountMinor.isBiggerThanValue(0))();
  TextColumn get type => text().check(type.isIn(const ['expense', 'income']))();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
}

/// The notifications inbox (PRD §5.4).
@DataClassName('NotificationRow')
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
}

/// Key-value settings (PRD §8 Preferences).
@DataClassName('PreferenceRow')
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
