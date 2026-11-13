// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csv_file_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the file_picker one.

@ProviderFor(csvFilePicker)
final csvFilePickerProvider = CsvFilePickerProvider._();

/// Overridden in `main.dart` with the file_picker one.

final class CsvFilePickerProvider
    extends $FunctionalProvider<CsvFilePicker, CsvFilePicker, CsvFilePicker>
    with $Provider<CsvFilePicker> {
  /// Overridden in `main.dart` with the file_picker one.
  CsvFilePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'csvFilePickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$csvFilePickerHash();

  @$internal
  @override
  $ProviderElement<CsvFilePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CsvFilePicker create(Ref ref) {
    return csvFilePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CsvFilePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CsvFilePicker>(value),
    );
  }
}

String _$csvFilePickerHash() => r'24bb165040d6de2b9bf397d6547b5b8be585f480';
