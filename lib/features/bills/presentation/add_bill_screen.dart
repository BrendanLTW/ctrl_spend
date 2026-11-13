import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/date_picker_sheet.dart';
import 'package:ctrl_spend/core/widgets/detail_rows.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/domain/bill_repository.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_labels.dart';
import 'package:ctrl_spend/features/bills/presentation/repeat_picker_sheet.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/categories/presentation/category_style_pickers.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/category_choice.dart';
import 'package:ctrl_spend/features/transactions/presentation/transaction_amount_card.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S28 New bill, and Edit bill from S27's actions. New bills open the
/// keypad straight away, as S12 does.
class AddBillScreen extends ConsumerStatefulWidget {
  const new({this.billId, super.key});

  /// Set to edit that bill.
  final int? billId;

  static const maxNameLength = 40;

  /// Days before the due date that "Remind me" means (PRD §5.11).
  static const remindDays = 2;

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  int _amount = 0;
  final _name = TextEditingController();
  int? _categoryId;
  BillRepeat _repeat = const BillRepeat(unit: RepeatUnit.month);
  late DateTime _nextDue = _today;
  bool _remind = true;
  CategoryIconKey _icon = CategoryIconKey.bolt;
  CategoryColorKey _colour = CategoryColorKey.yellow;
  Bill? _editing;

  bool get _isEdit => widget.billId != null;

  DateTime get _today {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openKeypad());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _prefill(Bill bill) {
    _editing = bill;
    _amount = bill.amountMinor;
    _name.text = bill.name;
    _categoryId = bill.categoryId;
    _repeat = bill.repeat;
    _nextDue = bill.nextDue;
    _remind = bill.remindDaysBefore != null;
    _icon = bill.iconKey;
    _colour = bill.colorKey;
  }

  Future<void> _openKeypad() => showKeypadSheet(
    context,
    initialMinor: _amount,
    onChanged: (minor) => setState(() => _amount = minor),
  );

  Future<void> _pickCategory(List<Category> choices, Category? selected) async {
    final picked = await showCategorySheet(
      context,
      choices: choices,
      selected: selected,
    );
    if (picked != null) setState(() => _categoryId = picked.id);
  }

  Future<void> _pickRepeat() async {
    final picked = await showRepeatPicker(
      context,
      current: _repeat,
      day: _nextDue.day,
    );
    if (picked != null) setState(() => _repeat = picked);
  }

  Future<void> _pickNextDue() async {
    final day = await showDatePickerSheet(
      context,
      title: context.l10n.billNextDueRow,
      initial: _nextDue,
      today: _today,
    );
    if (day != null) setState(() => _nextDue = day);
  }

  Future<void> _save(Category category) async {
    // Months and years come back to the next due day.
    final repeat = _repeat.copyWith(
      day: switch (_repeat.unit) {
        RepeatUnit.month || RepeatUnit.year => _nextDue.day,
        RepeatUnit.day || RepeatUnit.week => null,
      },
    );
    final remind = _remind ? AddBillScreen.remindDays : null;
    final repository = ref.read(billRepositoryProvider);
    final editing = _editing;
    if (editing == null) {
      await repository.add(
        name: _name.text,
        amountMinor: _amount,
        categoryId: category.id,
        repeat: repeat,
        nextDue: _nextDue,
        iconKey: _icon,
        colorKey: _colour,
        remindDaysBefore: remind,
      );
    } else {
      await repository.update(
        editing.copyWith(
          name: _name.text,
          amountMinor: _amount,
          categoryId: category.id,
          repeat: repeat,
          nextDue: _nextDue,
          iconKey: _icon,
          colorKey: _colour,
          remindDaysBefore: remind,
        ),
      );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    if (_isEdit && _editing == null) {
      final found = ref
          .watch(billsProvider)
          .value
          ?.where((b) => b.id == widget.billId)
          .firstOrNull;
      if (found != null) _prefill(found);
    }
    final currency = Currency.fromCode(
      ref.watch(preferencesProvider).value?.currencyCode ?? '',
    );
    final expense =
        ref.watch(categoriesProvider(type: TransactionType.expense)).value ??
        const <Category>[];
    // Archived categories stay out of the choices, unless it's this
    // bill's. A new bill starts in Bills, else the first expense category.
    final choices = [
      for (final c in expense)
        if (!c.archived || c.id == _editing?.categoryId) c,
    ];
    final selected =
        choices.where((c) => c.id == _categoryId).firstOrNull ??
        (_categoryId == null
            ? choices.where((c) => c.name == 'Bills').firstOrNull ??
                  choices.firstOrNull
            : null);

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
        title: Text(
          _isEdit ? l10n.editBill : l10n.newBill,
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
                  8,
                  AppSpacing.screenX,
                  16,
                ),
                children: [
                  TransactionAmountCard(
                    label: l10n.amountEachTime,
                    minor: _amount,
                    currency: currency,
                    income: false,
                    onTap: _openKeypad,
                  ),
                  const SizedBox(height: AppSpacing.sectionTop),
                  SectionLabel(l10n.details),
                  ListGroup(
                    children: [
                      DetailNameRow(
                        label: l10n.billNameRow,
                        hint: l10n.billNameHint,
                        controller: _name,
                        maxLength: AddBillScreen.maxNameLength,
                        onChanged: () => setState(() {}),
                      ),
                      DetailRow(
                        label: l10n.categoryRowLabel,
                        value: selected?.name ?? '',
                        tile: selected == null
                            ? null
                            : CategoryTile.forKey(
                                selected.iconKey,
                                color: selected.colorKey,
                                size: CategoryTileSize.small,
                              ),
                        onTap: () => _pickCategory(choices, selected),
                      ),
                      DetailRow(
                        label: l10n.billRepeatsRow,
                        value: l10n.repeatLabel(_repeat),
                        onTap: _pickRepeat,
                      ),
                      DetailRow(
                        label: l10n.billNextDueRow,
                        value: DateFormat('d MMM y', locale).format(_nextDue),
                        onTap: _pickNextDue,
                      ),
                      DetailToggleRow(
                        title: l10n.billRemindMe,
                        detail: l10n.billRemindDetail,
                        value: _remind,
                        onChanged: (on) => setState(() => _remind = on),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionTop),
                  SectionLabel(l10n.iconSection),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.r28),
                    ),
                    child: Column(
                      children: [
                        CategoryIconGrid(
                          icons: billPickerIcons,
                          selected: _icon,
                          onSelected: (icon) => setState(() => _icon = icon),
                        ),
                        const SizedBox(height: 16),
                        CategoryColourSwatches(
                          selected: _colour,
                          onSelected: (c) => setState(() => _colour = c),
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
                12,
              ),
              child: PrimaryButton(
                label: l10n.saveBill,
                onPressed:
                    _amount > 0 &&
                        _name.text.trim().isNotEmpty &&
                        selected != null
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
