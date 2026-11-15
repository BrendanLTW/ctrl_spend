import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/date_picker_sheet.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/segmented_control.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/features/transactions/presentation/category_picker_sheet.dart';
import 'package:ctrl_spend/features/transactions/presentation/delete_transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/entry_amount_card.dart';
import 'package:ctrl_spend/features/transactions/presentation/entry_fields.dart';
import 'package:ctrl_spend/l10n/date_labels.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S12 New expense, S13 New income and S45 Edit transaction (PRD §5.3):
/// the type, the amount typed on the keypad pinned below, a row of
/// category tiles with More (S46), an optional title, and Date and Note.
/// Save stays off, with a hint, until there's an amount and a category.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const new({
    this.transactionId,
    this.initialType = TransactionType.expense,
    super.key,
  });

  /// Set to edit that transaction (S45).
  final int? transactionId;
  final TransactionType initialType;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type = widget.initialType;
  int _amount = 0;
  int? _categoryId;
  late DateTime _occurredAt = ref.read(clockProvider)();
  final _title = TextEditingController();
  final _note = TextEditingController();
  Transaction? _editing;

  bool get _isEdit => widget.transactionId != null;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Fills the form from [found], once, the first time the data is in.
  void _prefill(Transaction found, List<Category> categories) {
    final category = categories
        .where((c) => c.id == found.categoryId)
        .firstOrNull;
    _editing = found;
    _type = found.type;
    _amount = found.amountMinor;
    _categoryId = found.categoryId;
    _occurredAt = found.occurredAt.toLocal();
    // A title equal to the category name was left blank.
    _title.text = found.title == category?.name ? '' : found.title;
    _note.text = found.note ?? '';
  }

  Future<void> _pickDate() async {
    final today = ref.read(clockProvider)();
    final day = await showDatePickerSheet(
      context,
      title: context.l10n.dateSheetTitle,
      initial: _occurredAt,
      today: today,
      lastDate: today,
    );
    if (day == null) return;
    // Keep the time of day; only the date changes.
    setState(
      () => _occurredAt = DateTime(
        day.year,
        day.month,
        day.day,
        _occurredAt.hour,
        _occurredAt.minute,
        _occurredAt.second,
      ),
    );
  }

  Future<void> _more() async {
    final picked = await showCategoryPickerSheet(
      context,
      type: _type,
      selectedId: _categoryId,
    );
    if (picked != null) setState(() => _categoryId = picked.id);
  }

  Future<void> _save(Category category) async {
    final repository = ref.read(transactionRepositoryProvider);
    final title = _title.text.trim();
    final note = _note.text.trim();
    final editing = _editing;
    if (editing == null) {
      await repository.add(
        amountMinor: _amount,
        type: _type,
        categoryId: category.id,
        occurredAt: _occurredAt,
        title: title,
        note: note.isEmpty ? null : note,
      );
    } else {
      await repository.update(
        editing.copyWith(
          amountMinor: _amount,
          type: _type,
          categoryId: category.id,
          occurredAt: _occurredAt.toUtc(),
          title: title.isEmpty ? category.name : title,
          note: note.isEmpty ? null : note,
        ),
      );
    }
    if (mounted) context.pop();
  }

  Future<void> _delete(Category? category, Currency currency) async {
    final editing = _editing;
    if (editing == null) return;
    final deleted = await confirmAndDeleteTransaction(
      context,
      ref,
      transaction: editing,
      category: category,
      currency: currency,
    );
    if (deleted && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    if (_isEdit && _editing == null) {
      final all = ref.watch(transactionsProvider()).value;
      final categories = ref.watch(categoriesProvider()).value;
      final found = all?.where((t) => t.id == widget.transactionId).firstOrNull;
      if (found != null && categories != null) _prefill(found, categories);
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currency = Currency.fromCode(
      ref.watch(preferencesProvider).value?.currencyCode ?? '',
    );
    final ofType =
        ref.watch(categoriesProvider(type: _type)).value ?? const <Category>[];
    final selected = ofType.where((c) => c.id == _categoryId).firstOrNull;
    // Archived categories stay out of the row, unless it's the one this
    // transaction already uses.
    final choices = [
      for (final c in ofType)
        if (!c.archived || c.id == selected?.id) c,
    ];
    final title = _isEdit
        ? l10n.editTransaction
        : _type == TransactionType.expense
        ? l10n.newExpense
        : l10n.newIncome;
    final canSave = _amount > 0 && selected != null;
    final dateLabel = _isEdit
        ? l10n.entryDateTime(
            DateFormat('d MMM', locale).format(_occurredAt),
            DateFormat('HH:mm', locale).format(_occurredAt),
          )
        : l10n.dateRowLabel(_occurredAt, ref.watch(clockProvider)(), locale);

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.close,
          icon: const AppIconView(AppIcon.close),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(title, style: text.header.copyWith(color: colors.ink)),
        actions: [
          if (_isEdit)
            TextButton(
              onPressed: () => _delete(selected, currency),
              style: TextButton.styleFrom(foregroundColor: colors.negative),
              child: Text(
                l10n.delete,
                style: text.rowTitleSm.copyWith(color: colors.negative),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 2, bottom: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenX,
                    ),
                    child: SegmentedControl<TransactionType>(
                      segments: [
                        (
                          value: TransactionType.expense,
                          label: l10n.expenseLabel,
                        ),
                        (
                          value: TransactionType.income,
                          label: l10n.incomeLabel,
                        ),
                      ],
                      selected: _type,
                      onChanged: (type) => setState(() {
                        if (type == _type) return;
                        _type = type;
                        // Categories belong to one type, so clear it.
                        _categoryId = null;
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenX,
                    ),
                    child: EntryAmountCard(
                      minor: _amount,
                      currency: currency,
                      income: _type == TransactionType.income,
                    ),
                  ),
                  CategoryTileRow(
                    choices: choices,
                    selected: selected,
                    onSelected: (c) => setState(() => _categoryId = c.id),
                    onMore: _more,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenX,
                      12,
                      AppSpacing.screenX,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EntryField(
                          icon: AppIcon.tag,
                          label: l10n.entryTitleHint,
                          controller: _title,
                          maxLength: maxTitleLength,
                        ),
                        const SizedBox(height: 8),
                        PairOrStack(
                          gap: 8,
                          children: [
                            EntryField(
                              icon: AppIcon.calendar,
                              label: dateLabel,
                              onTap: _pickDate,
                              compact: true,
                            ),
                            EntryField(
                              icon: AppIcon.note,
                              label: l10n.entryNoteHint,
                              controller: _note,
                              maxLength: maxNoteLength,
                              compact: true,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenX,
              ),
              child: MoneyKeypad(
                value: _amount,
                size: MoneyKeypadSize.entry,
                onChanged: (minor) => setState(() => _amount = minor),
              ),
            ),
            SizedBox(
              height: 20,
              child: canSave
                  ? null
                  : Center(
                      child: Text(
                        l10n.entrySaveHint,
                        textAlign: TextAlign.center,
                        style: text.hint.copyWith(color: colors.muted),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                24,
              ),
              child: PrimaryButton(
                label: l10n.save,
                size: PrimaryButtonSize.entry,
                onPressed: canSave ? () => _save(selected) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
