import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_window.g.dart';

/// "Hide amounts in app switcher" on Android, where the recents thumbnail
/// is taken by the system: FLAG_SECURE blanks it (S37). iOS covers the app
/// in Flutter instead.
abstract interface class SecureWindow {
  Future<void> setHidden({required bool hidden});
}

/// Overridden in `main.dart` with the platform channel one.
@Riverpod(keepAlive: true)
SecureWindow secureWindow(Ref ref) =>
    throw UnimplementedError('Override secureWindowProvider');
