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
    final pad = inSheet ? 6.0 : 8.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: inSheet ? colors.fillSoft : colors.surface,
        borderRadius: BorderRadius.circular(inSheet ? 22 : AppRadius.r24),
      ),
      // Same height for every segment, even if one label wraps.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, segment) in segments.indexed)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: segment.value == selected,
                  inMutuallyExclusiveGroup: true,
                  // The track's padding is part of each segment's tap area,
                  // so targets are 62 (54 in sheets) high (DESIGN §10).
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(segment.value),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        i == 0 ? pad : 0,
                        pad,
                        i == segments.length - 1 ? pad : 0,
                        pad,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        constraints: BoxConstraints(
                          minHeight: inSheet ? 42 : 46,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: segment.value == selected
                              ? colors.ink
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            inSheet ? AppRadius.r16 : AppRadius.r18,
                          ),
                        ),
                        // Two lines at large text sizes rather than "This p…".
                        child: Text(
                          segment.label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
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
              ),
          ],
        ),
      ),
    );
  }
}
