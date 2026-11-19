import 'dart:async';

import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/features/data_transfer/domain/csv_file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Import from CSV (S21): pick a file, then Import data checks, reviews
/// and saves it (S51–S53, S36). Cancelling the picker does nothing.
Future<void> importCsv(BuildContext context, WidgetRef ref) async {
  final file = await ref.read(csvFilePickerProvider).pickCsv();
  if (file == null || !context.mounted) return;
  unawaited(context.push(Routes.importData, extra: file));
}
