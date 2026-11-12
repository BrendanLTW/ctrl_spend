import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_sharer.g.dart';

/// Hands a file to the phone's share sheet (S35). The only way data leaves
/// the device (PRD §9 Privacy).
abstract interface class FileSharer {
  /// True when the user picked somewhere to send it, false when they
  /// dismissed the sheet.
  Future<bool> shareText({
    required String fileName,
    required String mimeType,
    required String contents,
  });
}

/// Overridden in `main.dart` with the share_plus one.
@Riverpod(keepAlive: true)
FileSharer fileSharer(Ref ref) =>
    throw UnimplementedError('Override fileSharerProvider');
