import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

typedef ChipOption<T> = ({T value, String label});

/// A sideways-scrolling row of single-choice chips (DESIGN §7): 44 high
/// pills, `ink` when selected.
class FilterChips<T> extends StatelessWidget {
  const new({
    required this.chips,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<ChipOption<T>> chips;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    // 14/600, as specified for chips.
    final style = context.text.navLabel;
    // Built in full (chips are few), so every chip can be scrolled to.
    return SizedBox(
      height: 44,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
        child: Row(
          children: [
            for (final (i, chip) in chips.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              _chip(context, chip, style),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, ChipOption<T> chip, TextStyle style) {
    final colors = context.colors;
    final on = chip.value == selected;
    return Semantics(
      button: true,
      selected: on,
      inMutuallyExclusiveGroup: true,
      label: chip.label,
      excludeSemantics: true,
      child: Material(
        color: on ? colors.ink : colors.surface,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(chip.value),
          highlightColor: on ? colors.inkPressed : colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              widthFactor: 1,
              child: Text(
                chip.label,
                style: style.copyWith(
                  color: on ? colors.onInk : colors.chipText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
