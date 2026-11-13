import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/chart_palette.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The icons and colours a user can pick (DESIGN §8, §3.3); Wallet and
/// Grey are for built-in categories.
const List<CategoryIconKey> pickerIcons = [
  CategoryIconKey.food,
  CategoryIconKey.coffee,
  CategoryIconKey.car,
  CategoryIconKey.bag,
  CategoryIconKey.bolt,
  CategoryIconKey.film,
  CategoryIconKey.heart,
  CategoryIconKey.gift,
  CategoryIconKey.book,
  CategoryIconKey.travel,
  CategoryIconKey.home,
  CategoryIconKey.phone,
];

/// The icons a bill can use (S28): its services first.
const List<CategoryIconKey> billPickerIcons = [
  CategoryIconKey.wifi,
  CategoryIconKey.tv,
  CategoryIconKey.phone,
  CategoryIconKey.bolt,
  CategoryIconKey.music,
  CategoryIconKey.home,
  CategoryIconKey.car,
  CategoryIconKey.heart,
  CategoryIconKey.book,
  CategoryIconKey.film,
  CategoryIconKey.gift,
  CategoryIconKey.bag,
];
final List<CategoryColorKey> pickerColours = [
  for (final key in CategoryColorKey.values)
    if (key != CategoryColorKey.neutral) key,
];

/// The longest category name (S23, S24).
const maxCategoryNameLength = 30;

/// The name with a preview tile of the chosen icon and colour.
class CategoryNameField extends StatelessWidget {
  const new({
    required this.controller,
    required this.icon,
    required this.colour,
    required this.maxLength,
    required this.onChanged,
    super.key,
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

/// 12 icons, 6 to a row (S24, S23; S28 with [billPickerIcons]).
class CategoryIconGrid extends StatelessWidget {
  const new({
    required this.selected,
    required this.onSelected,
    this.icons = pickerIcons,
    this.tileColor,
    super.key,
  });

  final CategoryIconKey selected;
  final ValueChanged<CategoryIconKey> onSelected;
  final List<CategoryIconKey> icons;

  /// Unselected tiles; `fillSoft` by default, for a sheet or card. S31
  /// passes `surface`, since its icons sit on the ground.
  final Color? tileColor;

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
        color: chosen ? colors.ink : tileColor ?? colors.fillSoft,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(icon),
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            height: 48,
            child: AppIconView(
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
      for (var row = 0; row * _perRow < icons.length; row++)
        Padding(
          padding: EdgeInsets.only(top: row == 0 ? 0 : 8),
          child: Row(
            children: [
              for (var col = 0; col < _perRow; col++) ...[
                if (col > 0) const SizedBox(width: 8),
                Expanded(child: _tile(context, icons[row * _perRow + col])),
              ],
            ],
          ),
        ),
    ],
  );
}

/// The 7 colour dots (S24, S23).
class CategoryColourSwatches extends StatelessWidget {
  const new({required this.selected, required this.onSelected, super.key});

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
