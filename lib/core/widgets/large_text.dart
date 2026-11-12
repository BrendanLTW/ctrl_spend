import 'package:flutter/widgets.dart';

/// Whether text is scaled to 150% or more, where side-by-side layouts no
/// longer fit a phone's width and should stack instead (DESIGN §10).
bool largeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(10) >= 15;

/// [start] filling the row with [end] after it, or, with [largeText],
/// [end] below [start] so neither is squeezed into a narrow column.
class SpreadOrStack extends StatelessWidget {
  const new({
    required this.start,
    required this.end,
    this.gap = 12,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  });

  final Widget start;
  final Widget end;
  final double gap;

  /// For the side-by-side row.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (largeText(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [start, const SizedBox(height: 4), end],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(child: start),
          SizedBox(width: gap),
          // Its natural width, but never more than 60% of the row, so a
          // long value wraps instead of overflowing.
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
            child: end,
          ),
        ],
      ),
    );
  }
}

/// Two widgets that share a row (S09's Spent and Income, Insights' stats),
/// stacked one per row with [largeText].
class PairOrStack extends StatelessWidget {
  const new({required this.children, this.gap = 12, super.key});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final stacked = largeText(context);
    return Flex(
      direction: stacked ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: stacked
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) SizedBox(width: gap, height: gap),
          if (stacked) child else Expanded(child: child),
        ],
      ],
    );
  }
}
