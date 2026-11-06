// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the user has finished onboarding (stored setting). Null until
/// the settings have loaded; the splash screen waits for it.

@ProviderFor(onboardingComplete)
final onboardingCompleteProvider = OnboardingCompleteProvider._();

/// Whether the user has finished onboarding (stored setting). Null until
/// the settings have loaded; the splash screen waits for it.

final class OnboardingCompleteProvider
    extends $FunctionalProvider<bool?, bool?, bool?>
    with $Provider<bool?> {
  /// Whether the user has finished onboarding (stored setting). Null until
  /// the settings have loaded; the splash screen waits for it.
  OnboardingCompleteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingCompleteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingCompleteHash();

  @$internal
  @override
  $ProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool? create(Ref ref) {
    return onboardingComplete(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }
}

String _$onboardingCompleteHash() =>
    r'8c2e1ac5a0cebd8e7236fac7f8c046ee9bef9644';
