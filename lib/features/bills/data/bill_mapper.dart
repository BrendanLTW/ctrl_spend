import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/db/stored_dates.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:drift/drift.dart';

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
    remindDaysBefore: remindDaysBefore,
    paused: paused,
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
    paused: Value(paused),
  );
}
