import 'dart:async';

import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';

/// In-memory settings for widget tests, where Drift's stream timers clash
/// with the fake clock.
class FakePreferencesRepository implements PreferencesRepository {
  new([Preferences initial = const Preferences()]) : _current = initial;

  Preferences _current;
  final _changes = StreamController<Preferences>.broadcast();

  @override
  Stream<Preferences> watch() {
    // Subscribes on listen, so an update right after can't be missed.
    StreamSubscription<Preferences>? changes;
    late final StreamController<Preferences> out;
    out = StreamController<Preferences>(
      onListen: () {
        out.add(_current);
        changes = _changes.stream.listen(out.add);
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
  Future<Preferences> read() async => _current;

  @override
  Future<void> update(Preferences Function(Preferences) change) async {
    _current = change(_current);
    _changes.add(_current);
  }
}
