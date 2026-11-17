import 'dart:async';
import 'dart:convert';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_file_picker.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/data_transfer/domain/import_summary.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_checking_view.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_done_view.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_failed_view.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_review_view.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Import data (PRD §5.8): S51 checks [file] row by row, then S36 lists
/// its problems or S52 reviews it, and S53 confirms. Nothing is saved
/// until Import on S52. Choose another file and Change start over.
class ImportScreen extends ConsumerStatefulWidget {
  const new({required this.file, super.key});

  final PickedFile file;

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  late PickedFile _file = widget.file;

  /// Bumped for each file, so a replaced check stops and is ignored.
  int _run = 0;
  ({int checked, int total}) _progress = (checked: 0, total: 0);
  List<ImportProblem>? _problems;
  ImportReview? _review;
  ImportDone? _done;

  @override
  void initState() {
    super.initState();
    unawaited(_check(widget.file));
  }

  Future<void> _check(PickedFile file) async {
    final run = ++_run;
    bool stale() => !mounted || run != _run;
    setState(() {
      _file = file;
      _progress = (checked: 0, total: 0);
      _problems = null;
      _review = null;
    });
    final now = ref.read(clockProvider)();
    ImportResult? result;
    try {
      result = await checkTransactionsCsv(
        utf8.decode(file.bytes),
        now: now,
        cancelled: stale,
        onProgress: (checked, total) {
          if (!stale()) {
            setState(() => _progress = (checked: checked, total: total));
          }
        },
      );
    } on FormatException {
      result = (rows: const [], problems: const [NotText()]);
    }
    if (result == null || stale()) return;
    if (result.problems.isNotEmpty) {
      setState(() => _problems = result!.problems);
      return;
    }
    if (result.rows.isEmpty) {
      if (!mounted) return;
      showAppToast(context, message: context.l10n.importEmpty);
      context.pop();
      return;
    }
    final categories = await ref.read(categoryRepositoryProvider).watch().first;
    final existing = await ref
        .read(transactionRepositoryProvider)
        .watch()
        .first;
    if (stale()) return;
    setState(
      () => _review = (
        rows: result!.rows,
        summary: summarizeImport(result.rows, categories: categories),
        duplicates: duplicateRows(
          result.rows,
          existing: existing,
          categories: categories,
        ),
      ),
    );
  }

  Future<void> _pickAnother() async {
    final file = await ref.read(csvFilePickerProvider).pickCsv();
    if (file != null && mounted) await _check(file);
  }

  Future<void> _import({required bool skipDuplicates}) async {
    final review = _review!;
    final rows = [
      for (final (i, r) in review.rows.indexed)
        if (!skipDuplicates || !review.duplicates.contains(i)) r,
    ];
    final categories = await ref.read(categoryRepositoryProvider).watch().first;
    // Summarised before saving, while the new categories are still new.
    final summary = summarizeImport(rows, categories: categories);
    await ref.read(transactionRepositoryProvider).importAll(rows);
    if (!mounted) return;
    setState(
      () => _done = (
        summary: summary,
        count: rows.length,
        skipped: skipDuplicates ? review.duplicates.length : 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final failed = _problems != null;
    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        // S36 goes back; the other steps close the flow.
        leading: IconButton(
          tooltip: failed ? l10n.back : l10n.close,
          icon: failed
              ? const AppIconView(
                  AppIcon.chevronLeft,
                  stroke: AppIconStroke.chevron,
                  size: 30,
                )
              : const AppIconView(AppIcon.close),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.importTitle,
          style: context.text.header.copyWith(color: colors.ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: switch ((_done, _review, _problems)) {
          (final done?, _, _) => ImportDoneView(done: done),
          (_, final review?, _) => ImportReviewView(
            file: _file,
            review: review,
            onChange: _pickAnother,
            onImport: _import,
          ),
          (_, _, final problems?) => ImportFailedView(
            fileName: _file.name,
            problems: problems,
            onChooseAnother: _pickAnother,
          ),
          _ => ImportCheckingView(
            fileName: _file.name,
            checked: _progress.checked,
            total: _progress.total,
          ),
        },
      ),
    );
  }
}
