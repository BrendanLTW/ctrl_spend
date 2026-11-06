import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// An expense or income category (PRD §8).
@freezed
abstract class Category with _$Category {
  const factory({
    required int id,
    required String name,
    required TransactionType type,
    required CategoryIconKey iconKey,
    required CategoryColorKey colorKey,
    required int sortOrder,

    /// Monthly limit; null means no limit.
    int? limitMinor,
    @Default(false) bool archived,
  }) = _Category;
}
