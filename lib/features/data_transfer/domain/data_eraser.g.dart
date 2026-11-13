// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_eraser.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation.

@ProviderFor(dataEraser)
final dataEraserProvider = DataEraserProvider._();

/// Overridden in `main.dart` with the Drift implementation.

final class DataEraserProvider
    extends $FunctionalProvider<DataEraser, DataEraser, DataEraser>
    with $Provider<DataEraser> {
  /// Overridden in `main.dart` with the Drift implementation.
  DataEraserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataEraserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataEraserHash();

  @$internal
  @override
  $ProviderElement<DataEraser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataEraser create(Ref ref) {
    return dataEraser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataEraser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataEraser>(value),
    );
  }
}

String _$dataEraserHash() => r'9d8d7c376f92681b30109762957bab9ae673ec56';
