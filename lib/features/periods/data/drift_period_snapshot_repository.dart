import 'package:ctrlspend/core/db/app_database.dart';
import 'package:ctrlspend/core/db/stored_dates.dart';
import 'package:ctrlspend/features/periods/domain/period_snapshot.dart';
import 'package:ctrlspend/features/periods/domain/period_snapshot_repository.dart';
import 'package:drift/drift.dart';

class DriftPeriodSnapshotRepository implements PeriodSnapshotRepository {
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<List<PeriodSnapshot>> watch() {
    final s = _db.periodSnapshots;
    final l = _db.periodSnapshotLimits;
    final query = _db.select(s).join([
      leftOuterJoin(l, l.snapshotId.equalsExp(s.id)),
    ])..orderBy([OrderingTerm.desc(s.periodStart)]);
    return query.watch().map((rows) {
      final byId = <int, PeriodSnapshotRow>{};
      final limits = <int, Map<int, int>>{};
      for (final row in rows) {
        final snapshot = row.readTable(s);
        byId[snapshot.id] = snapshot;
        final saved = limits[snapshot.id] ??= {};
        if (row.readTableOrNull(l) case final limit?) {
          saved[limit.categoryId] = limit.limitMinor;
        }
      }
      return [
        for (final row in byId.values)
          (
            period: (
              start: localDate(row.periodStart),
              end: localDate(row.periodEnd),
            ),
            budgetMinor: row.budgetMinor,
            limits: limits[row.id] ?? const {},
            spentMinor: row.spentMinor,
            incomeMinor: row.incomeMinor,
          ),
      ];
    });
  }

  @override
  Future<void> addAll(Iterable<PeriodSnapshot> snapshots) =>
      _db.transaction(() async {
        for (final snapshot in snapshots) {
          final start = storedDate(snapshot.period.start);
          final saved = await (_db.select(
            _db.periodSnapshots,
          )..where((s) => s.periodStart.equals(start))).getSingleOrNull();
          if (saved != null) continue;
          final id = await _db
              .into(_db.periodSnapshots)
              .insert(
                PeriodSnapshotsCompanion.insert(
                  periodStart: start,
                  periodEnd: storedDate(snapshot.period.end),
                  budgetMinor: Value(snapshot.budgetMinor),
                  spentMinor: snapshot.spentMinor,
                  incomeMinor: snapshot.incomeMinor,
                ),
              );
          for (final MapEntry(key: categoryId, value: limit)
              in snapshot.limits.entries) {
            await _db
                .into(_db.periodSnapshotLimits)
                .insert(
                  PeriodSnapshotLimitsCompanion.insert(
                    snapshotId: id,
                    categoryId: categoryId,
                    limitMinor: limit,
                  ),
                );
          }
        }
      });
}
