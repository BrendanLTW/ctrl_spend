import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Onboarding progress pills, 28 × 6 with a 6 px gap (DESIGN §6, §7).
/// [current] is 1-based; steps up to it are `ink`, the rest `stepOff`.
class StepIndicator extends StatelessWidget {
  const new({required this.current, required this.total, super.key})
    : assert(current >= 1 && current <= total, 'current in 1–total');

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: context.l10n.stepIndicator(current, total),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var step = 1; step <= total; step++) ...[
            if (step > 1) const SizedBox(width: 6),
            Container(
              width: 28,
              height: 6,
              decoration: ShapeDecoration(
                color: step <= current ? colors.ink : colors.stepOff,
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
