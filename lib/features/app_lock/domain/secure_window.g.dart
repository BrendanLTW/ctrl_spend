// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_window.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the platform channel one.

@ProviderFor(secureWindow)
final secureWindowProvider = SecureWindowProvider._();

/// Overridden in `main.dart` with the platform channel one.

final class SecureWindowProvider
    extends $FunctionalProvider<SecureWindow, SecureWindow, SecureWindow>
    with $Provider<SecureWindow> {
  /// Overridden in `main.dart` with the platform channel one.
  SecureWindowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureWindowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureWindowHash();

  @$internal
  @override
  $ProviderElement<SecureWindow> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecureWindow create(Ref ref) {
    return secureWindow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureWindow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureWindow>(value),
    );
  }
}

String _$secureWindowHash() => r'be5a1cc4eed513a13e95f8972bc2b715f13b4f4a';
