import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

typedef Segment<T> = ({T value, String label});

/// Equal-width segments with one selected (DESIGN §7): Week · Month ·
/// 6 months, Expense · Income. [inSheet] uses the smaller sheet variant on
/// `fillSoft`.
class SegmentedControl<T> extends StatelessWidget {
  const new({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.inSheet = false,
    super.key,
  });

  final List<Segment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool inSheet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.rowTitleSm;
    return Container(
      padding: EdgeInsets.all(inSheet ? 6 : 8),
      decoration: BoxDecoration(
        color: inSheet ? colors.fillSoft : colors.surface,
        borderRadius: BorderRadius.circular(inSheet ? 22 : AppRadius.r24),
      ),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: Semantics(
                button: true,
                selected: segment.value == selected,
                inMutuallyExclusiveGroup: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(segment.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: inSheet ? 42 : 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: segment.value == selected
                          ? colors.ink
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        inSheet ? AppRadius.r16 : AppRadius.r18,
                      ),
                    ),
                    child: Text(
                      segment.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style.copyWith(
                        color: segment.value == selected
                            ? colors.onInk
                            : colors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
