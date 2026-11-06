// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the user has finished onboarding.
// shortcut: in-memory placeholder, resets on restart; replace with the stored
// setting when the settings repository lands.

@ProviderFor(OnboardingComplete)
final onboardingCompleteProvider = OnboardingCompleteProvider._();

/// Whether the user has finished onboarding.
// shortcut: in-memory placeholder, resets on restart; replace with the stored
// setting when the settings repository lands.
final class OnboardingCompleteProvider
    extends $NotifierProvider<OnboardingComplete, bool> {
  /// Whether the user has finished onboarding.
  // shortcut: in-memory placeholder, resets on restart; replace with the stored
  // setting when the settings repository lands.
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
  OnboardingComplete create() => OnboardingComplete();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingCompleteHash() =>
    r'6aaebda68b991dcbe725c23c95397f90cfc15fd3';

/// Whether the user has finished onboarding.
// shortcut: in-memory placeholder, resets on restart; replace with the stored
// setting when the settings repository lands.

abstract class _$OnboardingComplete extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
