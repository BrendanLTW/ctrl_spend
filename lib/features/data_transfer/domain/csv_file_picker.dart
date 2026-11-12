import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'csv_file_picker.g.dart';

typedef PickedFile = ({String name, List<int> bytes});

/// Lets the user choose a CSV file (S21 Import from CSV, S36).
abstract interface class CsvFilePicker {
  /// Null when they cancel.
  Future<PickedFile?> pickCsv();
}

/// Overridden in `main.dart` with the file_picker one.
@Riverpod(keepAlive: true)
CsvFilePicker csvFilePicker(Ref ref) =>
    throw UnimplementedError('Override csvFilePickerProvider');
