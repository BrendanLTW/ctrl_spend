import 'dart:async';

import 'package:ctrlspend/features/periods/domain/period_snapshot.dart';
import 'package:ctrlspend/features/periods/domain/period_snapshot_repository.dart';

/// In-memory snapshots for widget tests, newest first; a period start
/// already saved is skipped, like the real one.
class FakePeriodSnapshotRepository implements PeriodSnapshotRepository {
  final _byStart = <DateTime, PeriodSnapshot>{};
  final _changes = StreamController<void>.broadcast();

  List<PeriodSnapshot> get all =>
      _byStart.values.toList()
        ..sort((a, b) => b.period.start.compareTo(a.period.start));

  @override
  Stream<List<PeriodSnapshot>> watch() {
    StreamSubscription<void>? changes;
    late final StreamController<List<PeriodSnapshot>> out;
    out = StreamController<List<PeriodSnapshot>>(
      onListen: () {
        out.add(all);
        changes = _changes.stream.listen((_) => out.add(all));
      },
      // Not returning the cancel future: under the widget test clock it
      // never completes, so `.first` would never return.
      onCancel: () {
        unawaited(changes?.cancel());
      },
    );
    return out.stream;
  }

  @override
  Future<void> addAll(Iterable<PeriodSnapshot> snapshots) async {
    for (final s in snapshots) {
      _byStart.putIfAbsent(s.period.start, () => s);
    }
    _changes.add(null);
  }
}
