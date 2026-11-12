import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/core/widgets/date_picker_sheet.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/segmented_control.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_export.dart';
import 'package:ctrl_spend/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum ExportRange { thisPeriod, allTime, custom }

/// S35 Export data: a range, which kinds to include, and Export CSV, which
/// hands `ctrlspend-YYYY-MM-DD.csv` to the share sheet (docs/csv-format.md).
class ExportScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportRange _range = ExportRange.allTime;
  bool _expenses = true;
  bool _income = true;
  bool _notes = true;

  /// The Custom range; starts as this period.
  Period? _custom;

  DateTime get _today => ref.read(clockProvider)();

  Period get _period => periodFor(
    _today,
    (ref.read(preferencesProvider).value ?? const Preferences()).monthStartDay,
  );

  Period? get _selectedRange => switch (_range) {
    ExportRange.thisPeriod => _period,
    ExportRange.allTime => null,
    ExportRange.custom => _custom ?? _period,
  };

  Future<void> _pick({required bool from}) async {
    final range = _custom ?? _period;
    final l10n = context.l10n;
    final day = await showDatePickerSheet(
      context,
      title: from ? l10n.fromLabel : l10n.toLabel,
      initial: from ? range.start : range.end,
      today: _today,
      firstDate: from ? null : range.start,
      lastDate: from ? range.end : null,
    );
    if (day == null) return;
    setState(
      () => _custom = from
          ? (start: day, end: range.end)
          : (start: range.start, end: day),
    );
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    final transactions = transactionsToExport(
      ref.read(transactionsProvider()).value ?? const <Transaction>[],
      expenses: _expenses,
      income: _income,
      range: _selectedRange,
    );
    if (transactions.isEmpty) {
      showAppToast(context, message: l10n.nothingToExport);
      return;
    }
    final name = exportFileName(_today);
    final shared = await ref
        .read(fileSharerProvider)
        .shareText(
          fileName: name,
          mimeType: 'text/csv',
          contents: transactionsToCsv(
            transactions,
            categories: {
              for (final c
                  in ref.read(categoriesProvider()).value ?? const <Category>[])
                c.id: c,
            },
            notes: _notes,
          ),
        );
    if (!shared || !mounted) return;
    showAppToast(
      context,
      message: l10n.exportSaved(transactions.length),
      detail: name,
      success: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Kept loaded, so Export reads them at once.
    ref
      ..watch(transactionsProvider())
      ..watch(categoriesProvider());
    final custom = _custom ?? _period;
    final day = DateFormat('d MMM yyyy', locale);

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.exportTitle,
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
                  4,
                  AppSpacing.screenX,
                  24,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.textX - AppSpacing.screenX,
                    ),
                    child: Text(
                      l10n.exportIntro,
                      style: text.body.copyWith(color: colors.muted),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionTop),
                  SectionLabel(l10n.rangeSection),
                  SegmentedControl<ExportRange>(
                    segments: [
                      (value: ExportRange.thisPeriod, label: l10n.thisPeriod),
                      (value: ExportRange.allTime, label: l10n.rangeAllTime),
                      (value: ExportRange.custom, label: l10n.rangeCustom),
                    ],
                    selected: _range,
                    onChanged: (range) => setState(() => _range = range),
                  ),
                  if (_range == ExportRange.custom) ...[
                    const SizedBox(height: AppSpacing.cardGap),
                    ListGroup(
                      children: [
                        ListGroupRow(
                          title: l10n.fromLabel,
                          value: day.format(custom.start),
                          onTap: () => _pick(from: true),
                        ),
                        ListGroupRow(
                          title: l10n.toLabel,
                          value: day.format(custom.end),
                          onTap: () => _pick(from: false),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sectionTop),
                  SectionLabel(l10n.includeSection),
                  ListGroup(
                    children: [
                      _IncludeRow(
                        label: l10n.expensesLabel,
                        value: _expenses,
                        onChanged: (on) => setState(() => _expenses = on),
                      ),
                      _IncludeRow(
                        label: l10n.incomeLabel,
                        value: _income,
                        onChanged: (on) => setState(() => _income = on),
                      ),
                      _IncludeRow(
                        label: l10n.notesLabel,
                        value: _notes,
                        onChanged: (on) => setState(() => _notes = on),
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
                16,
              ),
              child: PrimaryButton(
                label: l10n.exportCsvButton,
                onPressed: _expenses || _income ? _export : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A label and a toggle; tapping anywhere flips it, read as one toggle.
class _IncludeRow extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: context.text.rowTitle.copyWith(color: colors.ink),
                  ),
                ),
              ),
              AppToggle(
                value: value,
                onChanged: onChanged,
                semanticLabel: label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
