import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/core/widgets/stat_card.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

typedef InsightStat = ({String label, String value, String caption});

/// The S19/S20 card: an uppercase [label], the [amount] and a [caption],
/// an optional [chip] on the right, then the [chart] and its [legend].
/// Below it, the [stats] side by side.
class InsightChartCard extends StatelessWidget {
  const new({
    required this.label,
    required this.amount,
    required this.caption,
    required this.chart,
    required this.legend,
    required this.stats,
    this.chip,
    super.key,
  });

  final String label;
  final String amount;
  final String caption;
  final String? chip;
  final Widget chart;
  final List<(Color, String)> legend;
  final List<InsightStat> stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Builder(
                builder: (context) {
                  final summary = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: text.label.copyWith(color: colors.muted),
                      ),
                      // One line: the figure scales down rather than wrap.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          amount,
                          style: text.amount.copyWith(color: colors.ink),
                        ),
                      ),
                      Text(
                        caption,
                        style: text.body.copyWith(color: colors.muted),
                      ),
                    ],
                  );
                  final chipText = chip;
                  if (chipText == null) return summary;
                  return SpreadOrStack(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    start: summary,
                    end: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.raised,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        chipText,
                        style: text.caption.copyWith(
                          color: colors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              chart,
              const SizedBox(height: 16),
              // One line, as designed; shrinks rather than wraps.
              ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      for (final (i, (color, name)) in legend.indexed) ...[
                        if (i > 0) const SizedBox(width: 16),
                        _LegendDot(color, name),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (stats.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.cardGap),
          PairOrStack(
            children: [
              for (final stat in stats)
                StatCard(
                  label: stat.label,
                  value: Text(stat.value),
                  caption: stat.caption,
                  semanticLabel: l10n.statCaptionLabel(
                    stat.label,
                    stat.value,
                    stat.caption,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const new(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: context.text.caption.copyWith(color: context.colors.muted),
      ),
    ],
  );
}
