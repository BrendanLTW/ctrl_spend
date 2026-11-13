import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_eraser.g.dart';

/// Delete all data (S21): leaves the app as a fresh install would be.
abstract interface class DataEraser {
  /// Removes every transaction, category, notification and setting, all
  /// at once, then puts back the default categories. Settings return to
  /// their defaults, so onboarding starts again.
  Future<void> eraseAll();
}

/// Overridden in `main.dart` with the Drift implementation.
@Riverpod(keepAlive: true)
DataEraser dataEraser(Ref ref) =>
    throw UnimplementedError('Override dataEraserProvider');
