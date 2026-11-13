import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_repository.g.dart';

/// What [CategoryRepository.remove] did.
enum CategoryRemoval { deleted, archived }

/// Another category of the same type already has this name, ignoring case.
/// Archived categories count too.
final class DuplicateCategoryNameException implements Exception {
  const new(this.name);

  final String name;

  @override
  String toString() => 'DuplicateCategoryNameException: $name';
}

/// Expense and income categories (PRD §5.9, §8).
abstract interface class CategoryRepository {
  /// Categories ordered by `sortOrder`, then name. Leave a filter null to
  /// include both values.
  Stream<List<Category>> watch({TransactionType? type, bool? archived});

  /// Adds a category last in its type. The name is trimmed.
  /// Throws [DuplicateCategoryNameException].
  Future<Category> add({
    required String name,
    required TransactionType type,
    required CategoryIconKey iconKey,
    required CategoryColorKey colorKey,
    int? limitMinor,
  });

  /// Saves every field of [category]. The name is trimmed.
  /// Throws [DuplicateCategoryNameException].
  Future<void> update(Category category);

  Future<void> archive(int id);

  Future<void> restore(int id);

  /// Deletes the category if it has no transactions, otherwise archives it
  /// so its history stays intact.
  Future<CategoryRemoval> remove(int id);
}

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.
@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) =>
    throw UnimplementedError('Override categoryRepositoryProvider');

/// Categories, live, with [CategoryRepository.watch]'s filters.
@riverpod
Stream<List<Category>> categories(
  Ref ref, {
  TransactionType? type,
  bool? archived,
}) =>
    ref.watch(categoryRepositoryProvider).watch(type: type, archived: archived);
