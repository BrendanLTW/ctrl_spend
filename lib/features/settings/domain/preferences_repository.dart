import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preferences_repository.g.dart';

/// The user's settings (PRD §8 Preferences). Missing values read as their
/// defaults.
abstract interface class PreferencesRepository {
  Stream<Preferences> watch();

  Future<Preferences> read();

  /// Applies [change] to the current settings and saves the result, in one
  /// transaction so concurrent updates don't overwrite each other:
  /// `update((p) => p.copyWith(theme: AppTheme.dark))`.
  Future<void> update(Preferences Function(Preferences) change);
}

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.
@Riverpod(keepAlive: true)
PreferencesRepository preferencesRepository(Ref ref) =>
    throw UnimplementedError('Override preferencesRepositoryProvider');

/// The current settings, live.
@Riverpod(keepAlive: true)
Stream<Preferences> preferences(Ref ref) =>
    ref.watch(preferencesRepositoryProvider).watch();
