import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Every choice in a sheet, the selected one ticked (S12's More, S28).
/// Resolves to the tapped category, or null if dismissed.
Future<Category?> showCategorySheet(
  BuildContext context, {
  required List<Category> choices,
  Category? selected,
}) => showAppSheet<Category>(
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
