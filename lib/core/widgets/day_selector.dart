import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// One selectable day or option, 56 high (DESIGN §7): "1st" · "15th" on
/// S04, the day grid and "Last day of the month" on S32. Screens lay them
/// out.
class DaySelector extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
    this.compact = false,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Read instead of [label], e.g. "15th" for a grid's "15".
  final String? semanticLabel;

  /// 44 high, radius 16: S32's day grid.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.ink : colors.surface,
        borderRadius: BorderRadius.circular(
          compact ? AppRadius.r16 : AppRadius.r18,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: selected ? colors.inkPressed : colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            height: compact ? 44 : 56,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                style: context.text.rowTitle.copyWith(
                  color: selected ? colors.onInk : colors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
