import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/features/transactions/domain/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// The longest category name (PRD §5.9, §8).
const maxCategoryNameLength = 20;

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
