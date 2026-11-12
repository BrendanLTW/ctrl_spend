import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/core/widgets/amount_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/segmented_control.dart';
import 'package:ctrl_spend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens S24 New category: type, name with a live preview, icon, colour
/// and (for expenses) an optional monthly limit.
Future<void> showAddCategorySheet(BuildContext context) => showAppSheet<void>(
  context,
  title: context.l10n.newCategory,
  builder: (_) => const _AddCategoryBody(),
);

/// The icons and colours a user can pick (DESIGN §8, §3.3); Wallet and
/// Grey are for built-in categories.
final List<CategoryIconKey> pickerIcons = [
  for (final key in CategoryIconKey.values)
    if (key != CategoryIconKey.wallet) key,
];
final List<CategoryColorKey> pickerColours = [
  for (final key in CategoryColorKey.values)
    if (key != CategoryColorKey.neutral) key,
];

class _AddCategoryBody extends ConsumerStatefulWidget {
  const new();

  static const maxNameLength = 30;

  @override
  ConsumerState<_AddCategoryBody> createState() => _AddCategoryBodyState();
}

class _AddCategoryBodyState extends ConsumerState<_AddCategoryBody> {
  TransactionType _type = TransactionType.expense;
  CategoryIconKey _icon = CategoryIconKey.food;
  CategoryColorKey _colour = CategoryColorKey.orange;
  int? _limit;
  String? _error;
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Currency get _currency => Currency.fromCode(
    ref.read(preferencesProvider).value?.currencyCode ?? '',
  );

  Future<void> _editLimit(List<Category> expense) async {
    final result = await showAmountSheet(
      context,
      title: context.l10n.monthlyLimit,
      leading: CategoryTile.forKey(_icon, color: _colour),
      currency: _currency,
      initialMinor: _limit ?? 0,
      removable: _limit != null,
      // A new category has no id yet, so every existing limit counts.
      maxMinor: maxLimitFor(
        -1,
        categories: expense,
        budgetMinor: ref.read(preferencesProvider).value?.monthlyBudgetMinor,
      ),
    );
    if (result == null) return;
    setState(
      () => _limit = switch (result) {
        AmountSaved(:final minor) => minor,
        AmountRemoved() => null,
      },
    );
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    try {
      await ref
          .read(categoryRepositoryProvider)
          .add(
            name: name,
            type: _type,
            iconKey: _icon,
            colorKey: _colour,
            limitMinor: _type == TransactionType.expense ? _limit : null,
          );
      if (mounted) Navigator.of(context).pop();
    } on DuplicateCategoryNameException {
      setState(() => _error = context.l10n.duplicateCategory(_type.name, name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final expense =
        ref
            .watch(
              categoriesProvider(
                type: TransactionType.expense,
                archived: false,
              ),
            )
            .value ??
        const <Category>[];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedControl<TransactionType>(
              inSheet: true,
              segments: [
                (value: TransactionType.expense, label: l10n.expenseLabel),
                (value: TransactionType.income, label: l10n.incomeLabel),
              ],
              selected: _type,
              onChanged: (type) => setState(() {
                _type = type;
                _error = null;
              }),
            ),
            const SizedBox(height: 12),
            _NameField(
              controller: _name,
              icon: _icon,
              colour: _colour,
              maxLength: _AddCategoryBody.maxNameLength,
              onChanged: () => setState(() => _error = null),
            ),
            if (_error case final error?)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(
                  error,
                  style: text.caption.copyWith(
                    color: colors.negative,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SectionLabel(l10n.iconSection),
            _IconGrid(
              selected: _icon,
              onSelected: (icon) => setState(() => _icon = icon),
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.colourSection),
            _Swatches(
              selected: _colour,
              onSelected: (colour) => setState(() => _colour = colour),
            ),
            if (_type == TransactionType.expense) ...[
              const SizedBox(height: 20),
              _LimitRow(
                value: _limit == null
                    ? l10n.optional
                    : MoneyFormatter(_currency).formatCompact(_limit!),
                onTap: () => _editLimit(expense),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.createCategory,
              onPressed: _name.text.trim().isEmpty ? null : _create,
            ),
          ],
        ),
      ),
    );
  }
}

/// The name with a preview tile of the chosen icon and colour.
class _NameField extends StatelessWidget {
  const new({
    required this.controller,
    required this.icon,
    required this.colour,
    required this.maxLength,
    required this.onChanged,
  });

  final TextEditingController controller;
  final CategoryIconKey icon;
  final CategoryColorKey colour;
  final int maxLength;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final style = text.rowTitle.copyWith(color: colors.ink);
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.fillSoft,
        borderRadius: BorderRadius.circular(AppRadius.r24),
      ),
      child: Row(
        children: [
          CategoryTile.forKey(icon, color: colour),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: style,
              cursorColor: colors.ink,
              maxLength: maxLength,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration.collapsed(
                hintText: context.l10n.categoryName,
                hintStyle: style.copyWith(color: colors.muted),
              ).copyWith(counterText: ''),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconGrid extends StatelessWidget {
  const new({required this.selected, required this.onSelected});

  final CategoryIconKey selected;
  final ValueChanged<CategoryIconKey> onSelected;

  static const _perRow = 6;

  Widget _tile(BuildContext context, CategoryIconKey icon) {
    final colors = context.colors;
    final chosen = icon == selected;
    return Semantics(
      button: true,
      selected: chosen,
      inMutuallyExclusiveGroup: true,
      label: context.l10n.iconName(icon.name),
      excludeSemantics: true,
      child: Material(
        color: chosen ? colors.ink : colors.fillSoft,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(icon),
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            height: 48,
            child: Icon(
              categoryIcon(icon),
              size: 22,
              color: chosen ? colors.onInk : colors.ink,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var row = 0; row * _perRow < pickerIcons.length; row++)
        Padding(
          padding: EdgeInsets.only(top: row == 0 ? 0 : 8),
          child: Row(
            children: [
              for (var col = 0; col < _perRow; col++) ...[
                if (col > 0) const SizedBox(width: 8),
                Expanded(
                  child: _tile(context, pickerIcons[row * _perRow + col]),
                ),
              ],
            ],
          ),
        ),
    ],
  );
}

class _Swatches extends StatelessWidget {
  const new({required this.selected, required this.onSelected});

  final CategoryColorKey selected;
  final ValueChanged<CategoryColorKey> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final colour in pickerColours)
          Semantics(
            button: true,
            selected: colour == selected,
            inMutuallyExclusiveGroup: true,
            label: l10n.colourName(colour.name),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onSelected(colour),
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colour == selected ? colors.ink : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ChartPalette.of(colour),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "Monthly limit · Optional" (or the amount), opening the keypad.
class _LimitRow extends StatelessWidget {
  const new({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: '${l10n.monthlyLimit}, $value',
      excludeSemantics: true,
      child: Material(
        color: colors.fillSoft,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                const SizedBox(width: 18),
                Icon(Icons.track_changes_rounded, size: 22, color: colors.ink),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.monthlyLimit,
                    style: text.rowTitle.copyWith(color: colors.ink),
                  ),
                ),
                Text(
                  value,
                  style: text.rowTitleSm.copyWith(color: colors.muted),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 20, color: colors.ink),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
