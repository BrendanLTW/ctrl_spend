import 'package:ctrlspend/core/db/app_database.dart';
import 'package:ctrlspend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrlspend/features/categories/data/category_mapper.dart';
import 'package:ctrlspend/features/categories/domain/category.dart';
import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/features/categories/domain/category_repository.dart';
import 'package:ctrlspend/features/settings/data/preferences_mapper.dart';
import 'package:ctrlspend/features/transactions/domain/transaction.dart';
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
    await _checkLimits(
      Category(
        id: 0,
        name: name,
        type: type,
        iconKey: iconKey,
        colorKey: colorKey,
        sortOrder: 0,
        limitMinor: limitMinor,
      ),
    );
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
    await _checkLimits(category);
    await _db
        .update(_db.categories)
        .replace(category.copyWith(name: category.name.trim()).toCompanion());
  });

  @override
  Future<void> archive(int id) => _setArchived(id, archived: true);

  /// A restored category keeps its limit if it still fits in the budget,
  /// otherwise it comes back without one.
  @override
  Future<void> restore(int id) => _db.transaction(() async {
    final category = (await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(id))).getSingle()).toEntity();
    final restored = category.copyWith(archived: false);
    try {
      await _checkLimits(restored);
      await _setArchived(id, archived: false);
    } on LimitsOverBudgetException {
      await _db
          .update(_db.categories)
          .replace(restored.copyWith(limitMinor: null).toCompanion());
    }
  });

  @override
  Future<CategoryRemoval> remove(int id) => _db.transaction(() async {
    // In one transaction, so a transaction saved meanwhile can't be orphaned.
    final paid =
        await (_db.select(_db.transactions)
              ..where((t) => t.categoryId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    final billed =
        await (_db.select(_db.bills)
              ..where((b) => b.categoryId.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (paid != null || billed != null) {
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

  /// Throws [ArgumentError] for a blank name or one over
  /// [maxCategoryNameLength], and [DuplicateCategoryNameException] if
  /// another category of [type] has [name], compared like the table's
  /// NOCASE unique key. Call inside the write's transaction so nothing can
  /// take the name in between.
  Future<void> _checkNameFree(
    String name,
    TransactionType type, {
    int? exceptId,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > maxCategoryNameLength) {
      throw ArgumentError.value(name, 'name', 'must be 1–20 characters');
    }
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

  /// Throws [ArgumentError] for a limit on an income category or below 0,
  /// and [LimitsOverBudgetException] if saving [changed] would make the
  /// limits add up to more than the monthly budget, and more than they do
  /// now (PRD §5.6). Without a budget there's no cap.
  Future<void> _checkLimits(Category changed) async {
    final limit = changed.limitMinor;
    if (limit != null &&
        (limit < 0 || changed.type != TransactionType.expense)) {
      throw ArgumentError.value(limit, 'limitMinor', 'expense only, >= 0');
    }
    final budget = preferencesFromValues({
      for (final row in await _db.select(_db.preferences).get())
        row.key: row.value,
    }).monthlyBudgetMinor;
    if (budget == null) return;
    final current = [
      for (final row in await _db.select(_db.categories).get()) row.toEntity(),
    ];
    final after = [
      for (final c in current)
        if (c.id != changed.id) c,
      changed,
    ];
    final allocatedAfter = allocated(after);
    if (allocatedAfter > budget && allocatedAfter > allocated(current)) {
      throw LimitsOverBudgetException(
        allocatedMinor: allocatedAfter,
        budgetMinor: budget,
        maxForCategoryMinor:
            maxLimitFor(changed.id, categories: after, budgetMinor: budget) ??
            0,
      );
    }
  }
}
