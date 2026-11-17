import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/data/category_check.dart';
import 'package:ctrl_spend/features/transactions/data/transaction_mapper.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:drift/drift.dart';

class DriftTransactionRepository implements TransactionRepository {
  /// The second argument is the app clock, for the no-future-dates rule.
  new(this._db, [this._now = DateTime.now]);

  final AppDatabase _db;
  final Clock _now;

  @override
  Stream<List<Transaction>> watch({
    Period? period,
    TransactionType? type,
    int? categoryId,
    String? search,
  }) {
    final t = _db.transactions;
    final c = _db.categories;
    final query = _db.select(t).join([
      innerJoin(c, c.id.equalsExp(t.categoryId)),
    ])..orderBy([OrderingTerm.desc(t.occurredAt), OrderingTerm.desc(t.id)]);
    if (period != null) {
      // Whole seconds, not the stored text, so the midnight bounds are
      // exact whatever the fraction digits.
      final (:from, :to) = _utcSeconds(period);
      query.where(
        t.occurredAt.unixepoch.isBiggerOrEqualValue(from) &
            t.occurredAt.unixepoch.isSmallerThanValue(to),
      );
    }
    if (type != null) query.where(t.type.equals(type.name));
    if (categoryId != null) query.where(t.categoryId.equals(categoryId));
    final text = search?.trim() ?? '';
    if (text.isNotEmpty) {
      final pattern = '%${_escapeLike(text)}%';
      query.where(
        t.title.like(pattern, escapeChar: r'\') |
            t.note.like(pattern, escapeChar: r'\') |
            c.name.like(pattern, escapeChar: r'\'),
      );
    }
    return query.watch().map(
      (rows) => [for (final row in rows) row.readTable(t).toEntity()],
    );
  }

  @override
  Future<Transaction> add({
    required int amountMinor,
    required TransactionType type,
    required int categoryId,
    required DateTime occurredAt,
    String? title,
    String? note,
  }) => _db.transaction(() async {
    _checkAmount(amountMinor);
    final category = await _db.checkCategory(categoryId, type);
    final fields = _fields(title, note, category?.name ?? '');
    checkTransactionFields(
      title: fields.title,
      note: fields.note,
      occurredAt: occurredAt,
      now: _now(),
    );
    final row = await _db
        .into(_db.transactions)
        .insertReturning(
          TransactionsCompanion.insert(
            amountMinor: amountMinor,
            type: type.name,
            categoryId: categoryId,
            occurredAt: occurredAt.toUtc(),
            title: fields.title,
            note: Value(fields.note),
          ),
        );
    return row.toEntity();
  });

  /// [title] and [note] trimmed; a blank title is [categoryName] and a
  /// blank note is none.
  ({String title, String? note}) _fields(
    String? title,
    String? note,
    String categoryName,
  ) {
    final t = title?.trim() ?? '';
    final n = note?.trim() ?? '';
    return (title: t.isEmpty ? categoryName : t, note: n.isEmpty ? null : n);
  }

  @override
  Future<void> update(Transaction transaction) => _db.transaction(() async {
    _checkAmount(transaction.amountMinor);
    final current = await _byId(transaction.id);
    final category = await _db.checkCategory(
      transaction.categoryId,
      transaction.type,
      allowArchived: current.categoryId == transaction.categoryId,
    );
    final fields = _fields(
      transaction.title,
      transaction.note,
      category?.name ?? '',
    );
    checkTransactionFields(
      title: fields.title,
      note: fields.note,
      occurredAt: transaction.occurredAt,
      now: _now(),
    );
    await _db
        .update(_db.transactions)
        .replace(
          transaction
              .copyWith(title: fields.title, note: fields.note)
              .toCompanion(),
        );
  });

  @override
  Future<void> importAll(List<ImportedTransaction> rows) =>
      _db.transaction(() async {
        final c = _db.categories;
        final ids = {
          for (final row in await _db.select(c).get())
            (row.type, row.name.toLowerCase()): row.id,
        };
        final nextOrder = <String, int>{};
        Future<int> categoryFor(ImportedTransaction t) async {
          final key = (t.type.name, t.category.toLowerCase());
          if (ids[key] case final id?) return id;
          final maxOrder = c.sortOrder.max();
          final order =
              nextOrder[t.type.name] ??
              ((await (_db.selectOnly(c)
                            ..addColumns([maxOrder])
                            ..where(c.type.equals(t.type.name)))
                          .map((r) => r.read(maxOrder))
                          .getSingle() ??
                      -1) +
                  1);
          nextOrder[t.type.name] = order + 1;
          final id = await _db
              .into(c)
              .insert(
                CategoriesCompanion.insert(
                  name: t.category,
                  type: t.type.name,
                  iconKey: CategoryIconKey.wallet.name,
                  colorKey: CategoryColorKey.neutral.name,
                  sortOrder: order,
                ),
              );
          return ids[key] = id;
        }

        final now = _now();
        for (final t in rows) {
          _checkAmount(t.amountMinor);
          checkTransactionFields(
            title: t.title,
            note: t.note,
            occurredAt: t.occurredAt,
            now: now,
          );
          await _db
              .into(_db.transactions)
              .insert(
                TransactionsCompanion.insert(
                  amountMinor: t.amountMinor,
                  type: t.type.name,
                  categoryId: await categoryFor(t),
                  occurredAt: t.occurredAt.toUtc(),
                  title: t.title,
                  note: Value(t.note),
                ),
              );
        }
      });

  @override
  Future<Transaction> delete(int id) => _db.transaction(() async {
    final deleted = await _byId(id);
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    return deleted;
  });

  @override
  Future<void> restore(Transaction transaction) =>
      _db.into(_db.transactions).insert(transaction.toCompanion());

  Future<Transaction> _byId(int id) async => (await (_db.select(
    _db.transactions,
  )..where((t) => t.id.equals(id))).getSingle()).toEntity();

  void _checkAmount(int amountMinor) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', 'must be > 0');
    }
  }
}

/// The period's local days as UTC Unix seconds, end exclusive.
({int from, int to}) _utcSeconds(Period period) {
  final next = DateTime(period.end.year, period.end.month, period.end.day + 1);
  int seconds(DateTime local) => local.millisecondsSinceEpoch ~/ 1000;
  return (from: seconds(period.start), to: seconds(next));
}

String _escapeLike(String text) =>
    text.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
