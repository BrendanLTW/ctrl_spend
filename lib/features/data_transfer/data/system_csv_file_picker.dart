import 'package:ctrl_spend/features/data_transfer/domain/csv_file_picker.dart';
import 'package:file_picker/file_picker.dart';

/// [CsvFilePicker] on file_picker: the system picker, `.csv` files only.
class SystemCsvFilePicker implements CsvFilePicker {
  @override
  Future<PickedFile?> pickCsv() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    if (file == null) return null;
    return (name: file.name, bytes: await file.readAsBytes());
  }
}
