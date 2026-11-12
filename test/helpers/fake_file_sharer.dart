import 'package:ctrl_spend/features/data_transfer/domain/file_sharer.dart';

/// Keeps what would have gone to the share sheet.
class FakeFileSharer implements FileSharer {
  new({this.shares = true});

  /// What the user does with the sheet: send it somewhere, or dismiss it.
  final bool shares;
  final List<({String fileName, String mimeType, String contents})> shared = [];

  @override
  Future<bool> shareText({
    required String fileName,
    required String mimeType,
    required String contents,
  }) async {
    shared.add((fileName: fileName, mimeType: mimeType, contents: contents));
    return shares;
  }
}
