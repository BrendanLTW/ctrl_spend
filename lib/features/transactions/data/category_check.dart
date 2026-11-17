import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';

extension CategoryCheck on AppDatabase {
  /// Throws [CategoryTypeMismatchException] unless the category is of
  /// [type], and [ArchivedCategoryException] if it is archived and
  /// [allowArchived] is false. For transactions and bills. Returns the
  /// category, or null if there's none (left to the foreign key).
  Future<CategoryRow?> checkCategory(
    int categoryId,
    TransactionType type, {
    bool allowArchived = false,
  }) async {
    final category = await (select(
      categories,
    )..where((c) => c.id.equals(categoryId))).getSingleOrNull();
    // A missing category falls through to the foreign key error.
    if (category == null) return null;
    if (category.type != type.name) {
      throw CategoryTypeMismatchException(categoryId, type);
    }
    if (category.archived && !allowArchived) {
      throw ArchivedCategoryException(categoryId);
    }
    return category;
  }
}
