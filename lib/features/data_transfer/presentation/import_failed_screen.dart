import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_export.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/csv_import_flow.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S36 Import failed: nothing was imported; the file's problems by row,
/// Choose another file and Download a sample CSV.
class ImportFailedScreen extends ConsumerWidget {
  const new({required this.failure, super.key});

  final ImportFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final rows = {for (final p in failure.problems) p.row}.length;
    // The red category tile: a soft circle in light, a wash in dark.
    final alert = context.categoryColors.of(CategoryColorKey.red);

    Future<void> downloadSample() => ref
        .read(fileSharerProvider)
        .shareText(
          fileName: sampleCsvName,
          mimeType: 'text/csv',
          contents: sampleCsv,
        );

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const AppIconView(
            AppIcon.chevronLeft,
            stroke: AppIconStroke.chevron,
            size: 30,
          ),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.importTitle,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  24,
                  AppSpacing.screenX,
                  24,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: alert.tile,
                        shape: BoxShape.circle,
                      ),
                      child: AppIconView(
                        AppIcon.warning,
                        size: 38,
                        color: alert.icon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    header: true,
                    // One line, as designed, with the design's margins;
                    // shrinks on narrow screens.
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.importFailedTitle,
                          style: text.pageTitle.copyWith(color: colors.ink),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.importFailedBody(rows),
                    textAlign: TextAlign.center,
                    style: text.body.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 28),
                  SectionLabel(failure.fileName),
                  ListGroup(
                    children: [
                      for (final p in failure.problems)
                        ListGroupRow(
                          title: l10n.rowNumber(p.row),
                          subtitle: _describe(l10n, p),
                        ),
                    ],
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
                    onPressed: () => importCsv(context, ref, fromFailure: true),
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
        ),
      ),
    );
  }
}

String _describe(AppLocalizations l10n, ImportProblem problem) =>
    switch (problem) {
      NotText() => l10n.problemNotText,
      MissingColumns(:final columns) => l10n.problemMissingColumns(
        columns.join(', '),
      ),
      NotADate(:final value) => l10n.problemNotADate(value),
      NotATime(:final value) => l10n.problemNotATime(value),
      NotAType(:final value) => l10n.problemNotAType(value),
      NotAnAmount(:final value) => l10n.problemNotAnAmount(value),
      EmptyField(:final column) => l10n.problemEmpty(switch (column) {
        CsvColumns.date => l10n.columnDate,
        CsvColumns.type => l10n.columnType,
        CsvColumns.category => l10n.columnCategory,
        _ => l10n.columnAmount,
      }),
    };
