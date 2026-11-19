import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

/// Rows on a `fillSoft` card with dividers: a list inside a sheet, as
/// S44 shows it, so it stands out from the sheet in both themes.
class SheetListGroup extends StatelessWidget {
  const new({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.fillSoft,
      borderRadius: BorderRadius.circular(AppRadius.r28),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: colors.divider),
            child,
          ],
        ],
      ),
    );
  }
}
