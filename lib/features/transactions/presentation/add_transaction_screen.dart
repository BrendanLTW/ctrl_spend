import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_text_field.dart';
import 'package:ctrl_spend/core/widgets/date_picker_sheet.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/segmented_control.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/features/transactions/presentation/category_choice.dart';
import 'package:ctrl_spend/features/transactions/presentation/delete_transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/transaction_amount_card.dart';
import 'package:ctrl_spend/l10n/date_labels.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S12 New expense / New income and S13 Edit transaction. The note
/// becomes the title (or the category name if blank). New entries open
/// the keypad straight away.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const new({
    this.transactionId,
    this.initialType = TransactionType.expense,
    super.key,
  });

  /// Set to edit that transaction (S13).
  final int? transactionId;
  final TransactionType initialType;

  static const maxTitleLength = 60;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type = widget.initialType;
  int _amount = 0;
  int? _categoryId;
  late DateTime _occurredAt = ref.read(clockProvider)();
  final _note = TextEditingController();
  Transaction? _editing;

  bool get _isEdit => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openKeypad());
    }
  }

  @override
  void dispose() {
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
    // A title equal to the category name was a blank note.
    _note.text = found.title == category?.name ? '' : found.title;
  }

  Future<void> _openKeypad() => showKeypadSheet(
    context,
    initialMinor: _amount,
    onChanged: (minor) => setState(() => _amount = minor),
  );

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

  Future<void> _save(Category category) async {
    final note = _note.text.trim();
    final title = note.isEmpty ? category.name : note;
    final repository = ref.read(transactionRepositoryProvider);
    final editing = _editing;
    if (editing == null) {
      await repository.add(
        amountMinor: _amount,
        type: _type,
        categoryId: category.id,
        occurredAt: _occurredAt,
        title: title,
      );
    } else {
      await repository.update(
        editing.copyWith(
          amountMinor: _amount,
          type: _type,
          categoryId: category.id,
          occurredAt: _occurredAt.toUtc(),
          title: title,
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
    // Archived categories stay out of the choices, unless it's the one
    // this transaction already uses.
    final choices = [
      for (final c in ofType)
        if (!c.archived || c.id == selected?.id) c,
    ];
    final title = _isEdit
        ? l10n.editTransaction
        : _type == TransactionType.expense
        ? l10n.newExpense
        : l10n.newIncome;

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close_rounded),
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
                style: text.rowTitle.copyWith(color: colors.negative),
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  16,
                ),
                children: [
                  SegmentedControl<TransactionType>(
                    segments: [
                      (
                        value: TransactionType.expense,
                        label: l10n.expenseLabel,
                      ),
                      (value: TransactionType.income, label: l10n.incomeLabel),
                    ],
                    selected: _type,
                    onChanged: (type) => setState(() {
                      if (type == _type) return;
                      _type = type;
                      // Categories belong to one type, so clear the choice.
                      _categoryId = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  TransactionAmountCard(
                    minor: _amount,
                    currency: currency,
                    income: _type == TransactionType.income,
                    onTap: _openKeypad,
                  ),
                  const SizedBox(height: 24),
                  CategoryChoice(
                    choices: choices,
                    selected: selected,
                    onSelected: (c) => setState(() => _categoryId = c.id),
                  ),
                  const SizedBox(height: 24),
                  _DateRow(
                    label: l10n.dateRowLabel(
                      _occurredAt,
                      ref.watch(clockProvider)(),
                      locale,
                    ),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  AppTextField(
                    controller: _note,
                    hint: l10n.addNote,
                    icon: Icons.edit_note_rounded,
                    maxLength: AddTransactionScreen.maxTitleLength,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                12,
              ),
              child: PrimaryButton(
                label: l10n.save,
                onPressed: _amount > 0 && selected != null
                    ? () => _save(selected)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 20),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 22,
                  color: colors.muted,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.body.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: colors.ink),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
