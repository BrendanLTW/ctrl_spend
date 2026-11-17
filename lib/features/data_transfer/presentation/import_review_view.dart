import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_radio.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/message_box.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_file_picker.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/data_transfer/domain/import_summary.dart';
import 'package:ctrl_spend/l10n/date_labels.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// A checked file ready to import: its rows, their summary, and which
/// rows (by index) match transactions already here.
typedef ImportReview = ({
  List<ImportRow> rows,
  ImportSummary summary,
  Set<int> duplicates,
});

/// S52 Review: the file, "All {n} rows look good", dates, counts and new
/// categories, the duplicate choice (Skip by default), and Import.
class ImportReviewView extends StatefulWidget {
  const new({
    required this.file,
    required this.review,
    required this.onChange,
    required this.onImport,
    super.key,
  });

  final PickedFile file;
  final ImportReview review;
  final VoidCallback onChange;
  final Future<void> Function({required bool skipDuplicates}) onImport;

  @override
  State<ImportReviewView> createState() => _ImportReviewViewState();
}

class _ImportReviewViewState extends State<ImportReviewView> {
  bool _skip = true;
  bool _importing = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final ImportReview(:rows, :summary, :duplicates) = widget.review;
    final count = rows.length - (_skip ? duplicates.length : 0);
    const textInset = AppSpacing.textX - AppSpacing.screenX;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenX,
              4,
              AppSpacing.screenX,
              24,
            ),
            children: [
              _FileCard(
                name: widget.file.name,
                detail: l10n.importFileDetail(
                  rows.length,
                  _fileSize(l10n, widget.file.bytes.length),
                ),
                onChange: widget.onChange,
              ),
              const SizedBox(height: 12),
              MessageBox(
                l10n.importAllGood(rows.length),
                kind: MessageKind.success,
              ),
              const SizedBox(height: 12),
              ListGroup(
                children: [
                  KeyValueRow(
                    label: l10n.reviewDates,
                    value: dayRangeLabel(summary.first, summary.last, locale),
                  ),
                  KeyValueRow(
                    label: l10n.reviewTypes,
                    value: l10n.reviewTypesValue(
                      summary.expenses,
                      summary.income,
                    ),
                  ),
                  if (summary.newCategories.isNotEmpty)
                    KeyValueRow(
                      label: l10n.reviewNewCategories,
                      value: summary.newCategories.join(', '),
                    ),
                ],
              ),
              if (duplicates.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sectionTop),
                SectionLabel(l10n.duplicatesHeader(duplicates.length)),
                ListGroup(
                  children: [
                    _ChoiceRow(
                      title: l10n.skipDuplicates,
                      subtitle: l10n.skipDuplicatesDetail,
                      selected: _skip,
                      onTap: () => setState(() => _skip = true),
                    ),
                    _ChoiceRow(
                      title: l10n.importAnyway,
                      selected: !_skip,
                      onTap: () => setState(() => _skip = false),
                    ),
                  ],
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(textInset, 12, textInset, 0),
                child: Text(
                  l10n.importNote,
                  style: text.caption.copyWith(color: colors.muted),
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
            16,
          ),
          child: PrimaryButton(
            label: l10n.importCount(count),
            // Nothing left once every row is a skipped duplicate.
            onPressed: count == 0 || _importing
                ? null
                : () async {
                    setState(() => _importing = true);
                    await widget.onImport(skipDuplicates: _skip);
                    if (mounted) setState(() => _importing = false);
                  },
          ),
        ),
      ],
    );
  }
}

/// "18 KB": bytes under 1 KB, whole KB under 1 MB, then MB to one place.
String _fileSize(AppLocalizations l10n, int bytes) => switch (bytes) {
  < 1024 => l10n.fileSizeBytes(bytes),
  < 1024 * 1024 => l10n.fileSizeKb((bytes / 1024).round()),
  _ => l10n.fileSizeMb((bytes / (1024 * 1024)).toStringAsFixed(1)),
};

/// The file's tile, name, "214 rows · 18 KB" and Change.
class _FileCard extends StatelessWidget {
  const new({required this.name, required this.detail, required this.onChange});

  final String name;
  final String detail;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
      ),
      child: Row(
        children: [
          const CategoryTile(
            icon: AppIcon.document,
            color: CategoryColorKey.blue,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    // Two lines, so the .csv end stays visible.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.rowTitleSm.copyWith(color: colors.ink),
                  ),
                  Text(
                    detail,
                    style: text.caption.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              foregroundColor: colors.ink,
              overlayColor: colors.raised,
            ),
            child: Text(
              context.l10n.changeFile,
              style: text.navLabel.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// A radio, a title and an optional detail; the whole row picks it.
class _ChoiceRow extends StatelessWidget {
  const new({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                AppRadio(selected: selected),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.rowTitle.copyWith(color: colors.ink),
                      ),
                      if (subtitle case final subtitle?)
                        Text(
                          subtitle,
                          style: text.caption.copyWith(color: colors.muted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
