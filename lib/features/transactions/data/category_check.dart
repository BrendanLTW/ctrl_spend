import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';

extension CategoryCheck on AppDatabase {
  /// Throws [CategoryTypeMismatchException] unless the category is of
  /// [type], and [ArchivedCategoryException] if it is archived and
  /// [allowArchived] is false. For transactions and bills.
  Future<void> checkCategory(
    int categoryId,
    TransactionType type, {
    bool allowArchived = false,
  }) async {
    final category = await (select(
      categories,
    )..where((c) => c.id.equals(categoryId))).getSingleOrNull();
    // A missing category falls through to the foreign key error.
    if (category == null) return;
    if (category.type != type.name) {
      throw CategoryTypeMismatchException(categoryId, type);
    }
    if (category.archived && !allowArchived) {
      throw ArchivedCategoryException(categoryId);
    }
  }
}
