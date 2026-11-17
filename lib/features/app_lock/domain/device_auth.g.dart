// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the local_auth one.

@ProviderFor(deviceAuth)
final deviceAuthProvider = DeviceAuthProvider._();

/// Overridden in `main.dart` with the local_auth one.

final class DeviceAuthProvider
    extends $FunctionalProvider<DeviceAuth, DeviceAuth, DeviceAuth>
    with $Provider<DeviceAuth> {
  /// Overridden in `main.dart` with the local_auth one.
  DeviceAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceAuthHash();

  @$internal
  @override
  $ProviderElement<DeviceAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceAuth create(Ref ref) {
    return deviceAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceAuth>(value),
    );
  }
}

String _$deviceAuthHash() => r'49902fe8f81167c30190f3b0d8fd8d1d6750ffb9';
