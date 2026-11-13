import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:drift/drift.dart';

/// Calendar dates are stored as UTC midnight (schema v3), so a time zone
/// change can't move them, and used as local midnight.
DateTime storedDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

DateTime localDate(DateTime stored) {
  final utc = stored.toUtc();
  return DateTime(utc.year, utc.month, utc.day);
}

extension BillRowMapper on BillRow {
  Bill toEntity() => Bill(
    id: id,
    name: name,
    amountMinor: amountMinor,
    categoryId: categoryId,
    repeat: BillRepeat(
      unit: RepeatUnit.values.byName(repeatUnit),
      every: repeatEvery,
      day: repeatDay,
    ),
    nextDue: localDate(nextDue),
    iconKey: CategoryIconKey.values.byName(iconKey),
    colorKey: CategoryColorKey.values.byName(colorKey),
    remindDaysBefore: remindDaysBefore,
  );
}

extension BillMapper on Bill {
  /// The row to update.
  BillsCompanion toCompanion() => BillsCompanion(
    id: Value(id),
    name: Value(name),
    amountMinor: Value(amountMinor),
    categoryId: Value(categoryId),
    repeatUnit: Value(repeat.unit.name),
    repeatEvery: Value(repeat.every),
    repeatDay: Value(repeat.day),
    nextDue: Value(storedDate(nextDue)),
    remindDaysBefore: Value(remindDaysBefore),
    iconKey: Value(iconKey.name),
    colorKey: Value(colorKey.name),
  );
}
