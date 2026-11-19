import 'package:ctrlspend/core/money/money_formatter.dart';
import 'package:ctrlspend/core/period/clock.dart';
import 'package:ctrlspend/core/period/period.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/app_radio.dart';
import 'package:ctrlspend/core/widgets/app_sheet.dart';
import 'package:ctrlspend/core/widgets/category_tile.dart';
import 'package:ctrlspend/core/widgets/search_field.dart';
import 'package:ctrlspend/core/widgets/section_label.dart';
import 'package:ctrlspend/features/budgets/domain/budget_calculations.dart';
import 'package:ctrlspend/features/categories/domain/category.dart';
import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:ctrlspend/features/categories/domain/category_repository.dart';
import 'package:ctrlspend/features/categories/domain/default_categories.dart';
import 'package:ctrlspend/features/categories/presentation/add_category_sheet.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:ctrlspend/features/transactions/domain/transaction.dart';
import 'package:ctrlspend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S46 Choose category: search, every active category of [type] with its
/// limit status ("RM 72 left", "Over by RM 10") or "Added by you", and New
/// category (S24). Archived categories don't appear. Resolves to the
/// chosen or new category, or null if dismissed.
Future<Category?> showCategoryPickerSheet(
  BuildContext context, {
  required TransactionType type,
  int? selectedId,
}) async {
  final picked = await showAppSheet<Object>(
    context,
    title: context.l10n.chooseCategory,
    builder: (_) => _PickerBody(type: type, selectedId: selectedId),
  );
  if (picked is Category) return picked;
  if (picked != _newCategory || !context.mounted) return null;
  return await showAddCategorySheet(context, type: type);
}

/// What New category pops, to open S24 once S46 has closed.
const _newCategory = #newCategory;

/// Whether [c] is one the app seeded, by name and type (PRD §8); others
/// show "Added by you". A renamed default reads as added.
bool isDefaultCategory(Category c) => defaultCategories.any(
  (d) => d.type == c.type && d.name.toLowerCase() == c.name.toLowerCase(),
);

class _PickerBody extends ConsumerStatefulWidget {
  const new({required this.type, required this.selectedId});

  final TransactionType type;
  final int? selectedId;

  @override
  ConsumerState<_PickerBody> createState() => _PickerBodyState();
}

class _PickerBodyState extends ConsumerState<_PickerBody> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final formatter = MoneyFormatter(Currency.fromCode(prefs.currencyCode));
    final period = periodFor(ref.watch(clockProvider)(), prefs.monthStartDay);
    final spent = spentByCategory(
      ref.watch(transactionsProvider(period: period)).value ?? const [],
      period,
    );
    final query = _search.text.trim().toLowerCase();
    final choices = [
      for (final c
          in ref.watch(categoriesProvider(type: widget.type)).value ??
              const <Category>[])
        if (!c.archived &&
            (query.isEmpty || c.name.toLowerCase().contains(query)))
          c,
    ];

    String? status(Category c) {
      if (c.limitMinor case final limit?) {
        final left = limit - (spent[c.id] ?? 0);
        return left >= 0
            ? l10n.amountLeft(formatter.formatCompact(left))
            : l10n.overBy(formatter.formatCompact(-left));
      }
      return isDefaultCategory(c) ? null : l10n.addedByYou;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchField(
            controller: _search,
            hint: l10n.searchCategories,
            inSheet: true,
            onChanged: (_) => setState(() {}),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  SectionLabel(
                    widget.type == TransactionType.expense
                        ? l10n.expenseLabel
                        : l10n.incomeLabel,
                  ),
                  if (choices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        l10n.noCategoryMatch(_search.text.trim()),
                        textAlign: TextAlign.center,
                        style: text.body.copyWith(color: colors.muted),
                      ),
                    )
                  else
                    Material(
                      color: colors.ground,
                      borderRadius: BorderRadius.circular(AppRadius.r28),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (final (i, c) in choices.indexed) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: colors.divider,
                              ),
                            _PickerRow(
                              category: c,
                              subtitle: status(c),
                              selected: c.id == widget.selectedId,
                              onTap: () => Navigator.of(context).pop(c),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  _PickerRow.newCategory(
                    label: l10n.newCategory,
                    onTap: () => Navigator.of(context).pop(_newCategory),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                    child: Text(
                      l10n.pickerArchivedNote,
                      style: text.caption.copyWith(color: colors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A category with its status and a radio, or New category with a
/// chevron.
class _PickerRow extends StatelessWidget {
  const new({
    required Category this.category,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  }) : label = null;

  const new newCategory({required String this.label, required this.onTap})
    : category = null,
      subtitle = null,
      selected = false;

  final Category? category;
  final String? label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final c = category;
    final title = c?.name ?? label!;
    return Semantics(
      button: true,
      selected: c != null && selected,
      inMutuallyExclusiveGroup: c != null,
      label: [title, ?subtitle].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(AppRadius.r28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                if (c != null)
                  CategoryTile.forKey(c.iconKey, color: c.colorKey)
                else
                  const CategoryTile(
                    icon: AppIcon.add,
                    color: CategoryColorKey.neutral,
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                const SizedBox(width: 12),
                if (c != null)
                  AppRadio(selected: selected)
                else
                  AppIconView(
                    AppIcon.chevronRight,
                    stroke: AppIconStroke.chevron,
                    size: 20,
                    color: colors.ink,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
