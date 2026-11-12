import 'dart:convert';

import 'package:ctrl_spend/features/data_transfer/domain/file_sharer.dart';
import 'package:share_plus/share_plus.dart';

/// [FileSharer] on share_plus, which writes the bytes to a temporary file
/// itself, so no storage permission or extra package is needed.
class SharePlusFileSharer implements FileSharer {
  @override
  Future<bool> shareText({
    required String fileName,
    required String mimeType,
    required String contents,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            utf8.encode(contents),
            name: fileName,
            mimeType: mimeType,
          ),
        ],
        fileNameOverrides: [fileName],
      ),
    );
    // Some platforms can't tell what the user did; count that as shared.
    return result.status != ShareResultStatus.dismissed;
  }
}
