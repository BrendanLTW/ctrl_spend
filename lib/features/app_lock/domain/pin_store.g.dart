// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the secure storage one.

@ProviderFor(pinStore)
final pinStoreProvider = PinStoreProvider._();

/// Overridden in `main.dart` with the secure storage one.

final class PinStoreProvider
    extends $FunctionalProvider<PinStore, PinStore, PinStore>
    with $Provider<PinStore> {
  /// Overridden in `main.dart` with the secure storage one.
  PinStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinStoreHash();

  @$internal
  @override
  $ProviderElement<PinStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PinStore create(Ref ref) {
    return pinStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinStore>(value),
    );
  }
}

String _$pinStoreHash() => r'0fa007355c2ce1670f30d0a5c29115659ce3d9bd';
