import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:drift/drift.dart';

extension CategoryRowMapper on CategoryRow {
  Category toEntity() => Category(
    id: id,
    name: name,
    type: TransactionType.values.byName(type),
    iconKey: CategoryIconKey.values.byName(iconKey),
    colorKey: CategoryColorKey.values.byName(colorKey),
    sortOrder: sortOrder,
    limitMinor: limitMinor,
    archived: archived,
  );
}

extension CategoryMapper on Category {
  /// The row to update. For a new category, leave out the id with
  /// `toCompanion().copyWith(id: const Value.absent())`.
  CategoriesCompanion toCompanion() => CategoriesCompanion(
    id: Value(id),
    name: Value(name),
    type: Value(type.name),
    iconKey: Value(iconKey.name),
    colorKey: Value(colorKey.name),
    sortOrder: Value(sortOrder),
    limitMinor: Value(limitMinor),
    archived: Value(archived),
  );
}
