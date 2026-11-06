// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The stored Theme setting (S33) as a [ThemeMode]. System until the
/// settings have loaded. Change it with `PreferencesRepository.update`.

@ProviderFor(appThemeMode)
final appThemeModeProvider = AppThemeModeProvider._();

/// The stored Theme setting (S33) as a [ThemeMode]. System until the
/// settings have loaded. Change it with `PreferencesRepository.update`.

final class AppThemeModeProvider
    extends $FunctionalProvider<ThemeMode, ThemeMode, ThemeMode>
    with $Provider<ThemeMode> {
  /// The stored Theme setting (S33) as a [ThemeMode]. System until the
  /// settings have loaded. Change it with `PreferencesRepository.update`.
  AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  $ProviderElement<ThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeMode create(Ref ref) {
    return appThemeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$appThemeModeHash() => r'bf21ffd396967cefd28397edc1602ab352ff2cee';
