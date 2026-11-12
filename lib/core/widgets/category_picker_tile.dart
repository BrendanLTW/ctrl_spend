import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// A choosable category (DESIGN §7): a 60 × 60 tile with the label below
/// in uppercase; `ink` fill with an `onInk` icon when selected.
class CategoryPickerTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final AppIcon icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: selected ? colors.ink : colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r20),
              ),
              child: AppIconView(
                icon,
                size: 24,
                color: selected ? colors.onInk : colors.ink,
                stroke: AppIconStroke.tile,
              ),
            ),
            const SizedBox(height: 8),
            // Scales down to fit its column; the padding keeps neighbours
            // from running together at large text sizes.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  style: context.text.label.copyWith(color: colors.ink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
