import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/categories/data/category_mapper.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:drift/drift.dart';

class DriftCategoryRepository implements CategoryRepository {
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Category>> watch({TransactionType? type, bool? archived}) {
    final query = _db.select(_db.categories)
      ..orderBy([
        (c) => OrderingTerm(expression: c.sortOrder),
        (c) => OrderingTerm(expression: c.name),
      ]);
    if (type != null) query.where((c) => c.type.equals(type.name));
    if (archived != null) query.where((c) => c.archived.equals(archived));
    return query.watch().map(
      (rows) => [for (final row in rows) row.toEntity()],
    );
  }

  @override
  Future<Category> add({
    required String name,
    required TransactionType type,
    required CategoryIconKey iconKey,
    required CategoryColorKey colorKey,
    int? limitMinor,
  }) => _db.transaction(() async {
    await _checkNameFree(name, type);
    final maxOrder = _db.categories.sortOrder.max();
    final last =
        await (_db.selectOnly(_db.categories)
              ..addColumns([maxOrder])
              ..where(_db.categories.type.equals(type.name)))
            .map((row) => row.read(maxOrder))
            .getSingle();
    final row = await _db
        .into(_db.categories)
        .insertReturning(
          CategoriesCompanion.insert(
            name: name.trim(),
            type: type.name,
            iconKey: iconKey.name,
            colorKey: colorKey.name,
            limitMinor: Value(limitMinor),
            sortOrder: (last ?? -1) + 1,
          ),
        );
    return row.toEntity();
  });

  @override
  Future<void> update(Category category) => _db.transaction(() async {
    await _checkNameFree(category.name, category.type, exceptId: category.id);
    await _db
        .update(_db.categories)
        .replace(category.copyWith(name: category.name.trim()).toCompanion());
  });

  @override
  Future<void> archive(int id) => _setArchived(id, archived: true);

  @override
  Future<void> restore(int id) => _setArchived(id, archived: false);

  @override
  Future<CategoryRemoval> remove(int id) => _db.transaction(() async {
    // In one transaction, so a transaction saved meanwhile can't be orphaned.
    final used =
        await (_db.select(_db.transactions)
              ..where((t) => t.categoryId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (used != null) {
      await _setArchived(id, archived: true);
      return CategoryRemoval.archived;
    }
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    return CategoryRemoval.deleted;
  });

  Future<void> _setArchived(int id, {required bool archived}) =>
      (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(archived: Value(archived)),
      );

  /// Throws [DuplicateCategoryNameException] if another category of [type]
  /// has [name], compared like the table's NOCASE unique key. Call inside
  /// the write's transaction so nothing can take the name in between.
  Future<void> _checkNameFree(
    String name,
    TransactionType type, {
    int? exceptId,
  }) async {
    final trimmed = name.trim();
    final query = _db.select(_db.categories)
      ..where(
        (c) =>
            c.type.equals(type.name) &
            c.name.collate(Collate.noCase).equals(trimmed),
      );
    if (exceptId != null) query.where((c) => c.id.equals(exceptId).not());
    if (await query.get().then((rows) => rows.isNotEmpty)) {
      throw DuplicateCategoryNameException(trimmed);
    }
  }
}
