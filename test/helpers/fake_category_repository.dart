import 'dart:async';

import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/categories/domain/default_categories.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// In-memory categories for widget tests, seeded with the defaults (ids
/// 1–8, as on first launch). Drift's stream timers clash with the fake
/// clock.
class FakeCategoryRepository implements CategoryRepository {
  new() {
    for (final (i, c) in defaultCategories.indexed) {
      _byId[i + 1] = Category(
        id: i + 1,
        name: c.name,
        type: c.type,
        iconKey: c.icon,
        colorKey: c.colour,
        sortOrder: i,
      );
    }
  }

  final _byId = <int, Category>{};
  final _changes = StreamController<void>.broadcast();

  Category byName(String name) =>
      _byId.values.singleWhere((c) => c.name == name);

  List<Category> _matching({TransactionType? type, bool? archived}) =>
      _byId.values
          .where((c) => type == null || c.type == type)
          .where((c) => archived == null || c.archived == archived)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  @override
  Stream<List<Category>> watch({TransactionType? type, bool? archived}) {
    StreamSubscription<void>? changes;
    late final StreamController<List<Category>> out;
    out = StreamController<List<Category>>(
      onListen: () {
        out.add(_matching(type: type, archived: archived));
        changes = _changes.stream.listen(
          (_) => out.add(_matching(type: type, archived: archived)),
        );
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  @override
  Future<Category> add({
    required String name,
    required TransactionType type,
    required CategoryIconKey iconKey,
    required CategoryColorKey colorKey,
    int? limitMinor,
  }) async {
    final id = _byId.keys.fold(0, (a, b) => a > b ? a : b) + 1;
    final category = Category(
      id: id,
      name: name.trim(),
      type: type,
      iconKey: iconKey,
      colorKey: colorKey,
      sortOrder: id,
      limitMinor: limitMinor,
    );
    _byId[id] = category;
    _changes.add(null);
    return category;
  }

  @override
  Future<void> update(Category category) async {
    _byId[category.id] = category;
    _changes.add(null);
  }

  @override
  Future<void> archive(int id) => update(_byId[id]!.copyWith(archived: true));

  @override
  Future<void> restore(int id) => update(_byId[id]!.copyWith(archived: false));

  @override
  Future<CategoryRemoval> remove(int id) async {
    _byId.remove(id);
    _changes.add(null);
    return CategoryRemoval.deleted;
  }
}
