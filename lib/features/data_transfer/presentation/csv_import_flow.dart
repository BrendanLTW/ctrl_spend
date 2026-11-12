import 'dart:async';
import 'dart:convert';

import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_file_picker.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What S36 shows: the file and every problem in it.
typedef ImportFailure = ({String fileName, List<ImportProblem> problems});

/// Import from CSV (PRD §5.8): pick a file, check every row, then save all
/// of it or none. Problems open S36 (or replace it, [fromFailure]); a clean
/// file is saved and a toast says how many, closing S36 if it was open.
Future<void> importCsv(
  BuildContext context,
  WidgetRef ref, {
  bool fromFailure = false,
}) async {
  final file = await ref.read(csvFilePickerProvider).pickCsv();
  if (file == null || !context.mounted) return;
  final l10n = context.l10n;

  ImportResult result;
  try {
    result = parseTransactionsCsv(utf8.decode(file.bytes));
  } on FormatException {
    result = (rows: const [], problems: const [NotText()]);
  }

  if (result.problems.isNotEmpty) {
    final failure = (fileName: file.name, problems: result.problems);
    if (fromFailure) {
      context.pushReplacement(Routes.importFailed, extra: failure);
    } else {
      unawaited(context.push(Routes.importFailed, extra: failure));
    }
    return;
  }
  if (result.rows.isEmpty) {
    showAppToast(context, message: l10n.importEmpty);
    return;
  }
  await ref.read(transactionRepositoryProvider).importAll(result.rows);
  if (!context.mounted) return;
  // The toast lives in the root overlay, so it outlasts S36 closing.
  showAppToast(
    context,
    message: l10n.importedTransactions(result.rows.length),
    success: true,
  );
  if (fromFailure) context.pop();
}
