import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/category_picker_tile.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S12's "Select category": up to [quickCount] tiles in rows of four and
/// More, which lists every choice in a sheet. The selected category is
/// always among the tiles, even if it's further down the list.
class CategoryChoice extends StatelessWidget {
  const new({
    required this.choices,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  static const quickCount = 8;
  static const _perRow = 4;

  /// Active categories of the current type, in display order, plus the
  /// selected one if it's archived.
  final List<Category> choices;
  final Category? selected;
  final ValueChanged<Category> onSelected;

  List<Category> get _quick {
    final quick = choices.take(quickCount).toList();
    final chosen = selected;
    if (chosen != null && !quick.any((c) => c.id == chosen.id)) {
      if (quick.length == quickCount) quick.removeLast();
      quick.add(chosen);
    }
    return quick;
  }

  Future<void> _openMore(BuildContext context) async {
    final picked = await showAppSheet<Category>(
      context,
      title: context.l10n.categorySheetTitle,
      builder: (sheet) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheet).height * 0.6,
        ),
        child: SingleChildScrollView(
          child: ListGroup(
            children: [
              for (final c in choices)
                ListGroupRow(
                  leading: CategoryTile.forKey(c.iconKey, color: c.colorKey),
                  title: c.name,
                  selected: c.id == selected?.id,
                  onTap: () => Navigator.of(sheet).pop(c),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final quick = _quick;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(width: AppSpacing.textX - AppSpacing.screenX),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.selectCategory.toUpperCase(),
                  style: text.label.copyWith(color: colors.muted),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openMore(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                foregroundColor: colors.ink,
                overlayColor: colors.raised,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.more,
                    style: text.rowTitle.copyWith(color: colors.ink),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.ink,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var row = 0; row * _perRow < quick.length; row++)
          Padding(
            padding: EdgeInsets.only(top: row == 0 ? 0 : 16),
            child: Row(
              children: [
                for (var col = 0; col < _perRow; col++)
                  Expanded(
                    child: switch (row * _perRow + col) {
                      final i when i < quick.length => CategoryPickerTile(
                        icon: categoryIcon(quick[i].iconKey),
                        label: quick[i].name,
                        selected: quick[i].id == selected?.id,
                        onTap: () => onSelected(quick[i]),
                      ),
                      _ => const SizedBox(),
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
