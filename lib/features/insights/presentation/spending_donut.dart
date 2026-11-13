import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/donut_painter.dart';
import 'package:flutter/material.dart';

/// S18's ring: one arc per category in its chart colour, with the period
/// total in the middle. With no [segments] it's S40's empty grey ring.
/// Read by screen readers as [semanticLabel].
class SpendingDonut extends StatelessWidget {
  const new({
    required this.segments,
    required this.caption,
    required this.totalMinor,
    required this.currency,
    required this.semanticLabel,
    super.key,
  });

  final List<(Color, double)> segments;

  /// "Spent 15 Oct – 14 Nov", or "Spent" when empty.
  final String caption;
  final int totalMinor;
  final Currency currency;
  final String semanticLabel;

  static const double _size = 236;
  static const double _stroke = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final empty = segments.isEmpty;
    final painter = empty
        // Short grey arcs whose caps overlap, so the ring looks beaded.
        ? DonutPainter(
            segments: [for (var i = 0; i < 18; i++) (colors.raised, 1.0)],
            stroke: _stroke,
            gap: 0.12,
          )
        : DonutPainter(segments: segments, stroke: _stroke, gap: 0.5);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: _size,
        child: CustomPaint(
          painter: painter,
          child: Padding(
            padding: const EdgeInsets.all(_stroke * 2),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      caption,
                      style: text.label.copyWith(color: colors.muted),
                    ),
                    if (empty)
                      Text(
                        MoneyFormatter(currency).formatCompact(totalMinor),
                        style: text.amount.copyWith(color: colors.ink),
                      )
                    else
                      AmountText(
                        totalMinor,
                        currency: currency,
                        style: text.amount.copyWith(color: colors.ink),
                        centsColor: colors.ink,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
