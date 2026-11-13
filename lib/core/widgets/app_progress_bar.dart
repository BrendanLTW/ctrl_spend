import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A 10 px pill progress bar (DESIGN §7). [value] is clamped to 0–1, so an
/// over-budget bar shows full. Pair the fill colour with text (§3.5).
class AppProgressBar extends StatelessWidget {
  const new({
    required this.value,
    required this.semanticLabel,
    this.color,
    this.onHero = false,
    super.key,
  });

  final double value;

  /// Read by screen readers, e.g. "38% of monthly budget spent".
  final String semanticLabel;

  /// The fill, usually from the budget status. Defaults to `ink`, or white
  /// on the hero.
  final Color? color;

  /// The hero card's style: `heroTrack` track, white fill.
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = color ?? (onHero ? Colors.white : colors.ink);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        height: 10,
        decoration: ShapeDecoration(
          color: onHero ? colors.heroTrack : colors.raised,
          shape: const StadiumBorder(),
        ),
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: value.isNaN ? 0 : value.clamp(0, 1),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: fill,
              shape: const StadiumBorder(),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
