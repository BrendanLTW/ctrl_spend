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

  /// The bill this payment came from (S27 "Paid this period"). Added in
  /// schema v3.
  IntColumn get billId => integer().nullable().references(
    Bills,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

/// Recurring bills (PRD §5.11, v1.1). A repeat is a unit and a count:
/// every 2 weeks is (week, 2), every 3 months is (month, 3). `repeatDay`
/// keeps the day of the month for monthly and yearly bills, so one due on
/// the 31st returns to it after February. `nextDue` is a calendar date,
/// stored as UTC midnight.
@DataClassName('BillRow')
class Bills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get amountMinor =>
      integer().check(amountMinor.isBiggerThanValue(0))();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get repeatUnit =>
      text().check(repeatUnit.isIn(const ['day', 'week', 'month', 'year']))();
  IntColumn get repeatEvery =>
      integer().check(repeatEvery.isBiggerOrEqualValue(1))();
  IntColumn get repeatDay =>
      integer().nullable().check(repeatDay.isBetweenValues(1, 31))();
  DateTimeColumn get nextDue => dateTime()();
  IntColumn get remindDaysBefore =>
      integer().nullable().check(remindDaysBefore.isBiggerOrEqualValue(0))();

  /// The row's tile on S27. Added in schema v4; earlier bills get the
  /// Bills category's look.
  TextColumn get iconKey => text().withDefault(const Constant('bolt'))();
  TextColumn get colorKey => text().withDefault(const Constant('yellow'))();

  /// A paused bill is left out of Upcoming totals, "Left after bills" and
  /// reminders (PRD §5.11). Added in schema v5.
  BoolColumn get paused => boolean().withDefault(const Constant(false))();
}

/// Savings goals (PRD §5.12, v1.1). `targetMonth` is the first of the
/// month, stored as UTC midnight.
@DataClassName('GoalRow')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconKey => text()();
  IntColumn get targetMinor =>
      integer().check(targetMinor.isBiggerThanValue(0))();
  DateTimeColumn get targetMonth => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// When the goal was made, for its on-track plan (PRD §5.12). Added in
  /// schema v5; earlier goals got their first contribution's date.
  DateTimeColumn get createdAt => dateTime()();
}

/// Money added to (positive) or withdrawn from (negative) a goal. Never
/// spending (PRD §8). `date` is a calendar date, stored as UTC midnight.
@DataClassName('GoalContributionRow')
class GoalContributions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  IntColumn get amountMinor => integer().check(amountMinor.equals(0).not())();
  TextColumn get label => text()();
  DateTimeColumn get date => dateTime()();
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

  /// The category a budget alert or income row is about, for its tile
  /// (S14). Added in schema v2.
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

/// A period's budget and totals, saved when it ends (PRD §6.2, §8), so
/// later budget changes don't rewrite history. Dates are calendar dates,
/// stored as UTC midnight. Added in schema v5.
@DataClassName('PeriodSnapshotRow')
class PeriodSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get periodStart => dateTime().unique()();
  DateTimeColumn get periodEnd => dateTime()();
  IntColumn get budgetMinor =>
      integer().nullable().check(budgetMinor.isBiggerOrEqualValue(0))();
  IntColumn get spentMinor =>
      integer().check(spentMinor.isBiggerOrEqualValue(0))();
  IntColumn get incomeMinor =>
      integer().check(incomeMinor.isBiggerOrEqualValue(0))();
}

/// A snapshot's category limits (PeriodSnapshot `limits`).
@DataClassName('PeriodSnapshotLimitRow')
class PeriodSnapshotLimits extends Table {
  IntColumn get snapshotId =>
      integer().references(PeriodSnapshots, #id, onDelete: KeyAction.cascade)();

  /// A category with transactions is archived, never deleted, so only a
  /// limit on an unused category can go with it.
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  IntColumn get limitMinor =>
      integer().check(limitMinor.isBiggerOrEqualValue(0))();

  @override
  Set<Column> get primaryKey => {snapshotId, categoryId};
}

/// Key-value settings (PRD §8 Preferences).
@DataClassName('PreferenceRow')
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
