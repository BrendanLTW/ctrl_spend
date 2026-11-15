import 'package:ctrl_spend/features/periods/domain/period_snapshot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'period_snapshot_repository.g.dart';

/// Saved period snapshots (PRD §8).
abstract interface class PeriodSnapshotRepository {
  /// Every snapshot, newest first.
  Stream<List<PeriodSnapshot>> watch();

  /// Saves [snapshots] in one transaction. One whose period start is
  /// already saved is skipped: snapshots are never rewritten.
  Future<void> addAll(Iterable<PeriodSnapshot> snapshots);
}

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.
@Riverpod(keepAlive: true)
PeriodSnapshotRepository periodSnapshotRepository(Ref ref) =>
    throw UnimplementedError('Override periodSnapshotRepositoryProvider');

/// Every snapshot, live, newest first.
@riverpod
Stream<List<PeriodSnapshot>> periodSnapshots(Ref ref) =>
    ref.watch(periodSnapshotRepositoryProvider).watch();
