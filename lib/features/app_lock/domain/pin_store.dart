import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pin_store.g.dart';

/// PIN digits (S64).
const pinLength = 4;

/// The app lock PIN (PRD §5.8). It lives in the phone's secure storage,
/// never in the database (CLAUDE.md), and only as a salted hash.
abstract interface class PinStore {
  Future<bool> hasPin();

  /// Replaces any PIN with [pin].
  Future<void> save(String pin);

  /// Whether [pin] is the saved one; false when there's none.
  Future<bool> check(String pin);

  /// Forgets the PIN: turning app lock off, or Erase all data.
  Future<void> clear();
}

/// Overridden in `main.dart` with the secure storage one.
@Riverpod(keepAlive: true)
PinStore pinStore(Ref ref) =>
    throw UnimplementedError('Override pinStoreProvider');
