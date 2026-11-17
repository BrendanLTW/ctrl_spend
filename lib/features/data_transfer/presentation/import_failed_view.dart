import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/state_view.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_export.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S36 Import failed: nothing was imported; the file's problems by row,
/// Choose another file and Download a sample CSV.
class ImportFailedView extends ConsumerWidget {
  const new({
    required this.fileName,
    required this.problems,
    required this.onChooseAnother,
    super.key,
  });

  final String fileName;
  final List<ImportProblem> problems;
  final VoidCallback onChooseAnother;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rows = {for (final p in problems) p.row}.length;

    Future<void> downloadSample() => ref
        .read(fileSharerProvider)
        .shareText(
          fileName: sampleCsvName,
          mimeType: 'text/csv',
          contents: sampleCsv,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 32, bottom: 24),
            children: [
              StateView(
                icon: AppIcon.warning,
                tone: StateTone.error,
                title: l10n.importFailedTitle,
                body: l10n.importFailedBody(rows),
              ),
              const SizedBox(height: AppSpacing.sectionTop),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenX,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(fileName),
                    ListGroup(
                      children: [
                        for (final p in problems)
                          ListGroupRow(
                            title: l10n.rowNumber(p.row),
                            subtitle: _describe(l10n, p),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            0,
            AppSpacing.screenX,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryButton(
                label: l10n.chooseAnotherFile,
                onPressed: onChooseAnother,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextLink(
                  label: l10n.downloadSampleCsv,
                  onPressed: downloadSample,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _describe(
  AppLocalizations l10n,
  ImportProblem problem,
) => switch (problem) {
  NotText() => l10n.problemNotText,
  MissingColumns(:final columns) => l10n.problemMissingColumns(
    columns.join(', '),
  ),
  NotADate(:final value) => l10n.problemNotADate(value),
  NotATime(:final value) => l10n.problemNotATime(value),
  NotAType(:final value) => l10n.problemNotAType(value),
  NotAnAmount(:final value) => l10n.problemNotAnAmount(value),
  TooLong(:final column, :final max) => l10n.problemTooLong(switch (column) {
    CsvColumns.title => l10n.columnTitle,
    CsvColumns.note => l10n.columnNote,
    _ => l10n.columnCategory,
  }, max),
  FutureDate(:final value) => l10n.problemFutureDate(value),
  TooManyRows(:final count) => l10n.problemTooManyRows(count, maxImportRows),
  EmptyField(:final column) => l10n.problemEmpty(switch (column) {
    CsvColumns.date => l10n.columnDate,
    CsvColumns.type => l10n.columnType,
    CsvColumns.category => l10n.columnCategory,
    _ => l10n.columnAmount,
  }),
};
