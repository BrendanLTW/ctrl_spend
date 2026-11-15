// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(snapshotService)
final snapshotServiceProvider = SnapshotServiceProvider._();

final class SnapshotServiceProvider
    extends
        $FunctionalProvider<SnapshotService, SnapshotService, SnapshotService>
    with $Provider<SnapshotService> {
  SnapshotServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'snapshotServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$snapshotServiceHash();

  @$internal
  @override
  $ProviderElement<SnapshotService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SnapshotService create(Ref ref) {
    return snapshotService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SnapshotService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SnapshotService>(value),
    );
  }
}

String _$snapshotServiceHash() => r'c814271f9b0340501fe9257ae3d36740df69f5bf';
