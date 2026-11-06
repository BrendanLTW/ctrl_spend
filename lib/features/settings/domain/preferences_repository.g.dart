// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

@ProviderFor(preferencesRepository)
final preferencesRepositoryProvider = PreferencesRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

final class PreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          PreferencesRepository,
          PreferencesRepository,
          PreferencesRepository
        >
    with $Provider<PreferencesRepository> {
  /// Overridden in `main.dart` with the Drift implementation, so screens
  /// never import `data/`.
  PreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PreferencesRepository create(Ref ref) {
    return preferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesRepository>(value),
    );
  }
}

String _$preferencesRepositoryHash() =>
    r'9ecd7b4251068c0bb87d8fe75caff1149821382c';

/// The current settings, live.

@ProviderFor(preferences)
final preferencesProvider = PreferencesProvider._();

/// The current settings, live.

final class PreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Preferences>,
          Preferences,
          Stream<Preferences>
        >
    with $FutureModifier<Preferences>, $StreamProvider<Preferences> {
  /// The current settings, live.
  PreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesHash();

  @$internal
  @override
  $StreamProviderElement<Preferences> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Preferences> create(Ref ref) {
    return preferences(ref);
  }
}

String _$preferencesHash() => r'07b299ef74039735aecd5a794fc8df97f44d3a42';
