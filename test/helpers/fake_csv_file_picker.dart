import 'dart:convert';

import 'package:ctrl_spend/features/data_transfer/domain/csv_file_picker.dart';

/// Hands back [files] in turn, as if the user picked each; null cancels.
class FakeCsvFilePicker implements CsvFilePicker {
  final List<PickedFile?> files = [];
  int picks = 0;

  void willPick(String name, String text) =>
      files.add((name: name, bytes: utf8.encode(text)));

  @override
  Future<PickedFile?> pickCsv() async {
    picks++;
    return files.isEmpty ? null : files.removeAt(0);
  }
}
