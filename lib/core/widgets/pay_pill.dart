import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// The small Pay pill at the end of a bill row (DESIGN §7, S27): 34 high,
/// `ink`, 13/600, with a 44 px touch area. [semanticLabel] names the bill,
/// e.g. "Pay Netflix".
class PayPill extends StatelessWidget {
  const new({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.ink,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 34),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Text(
                      label,
                      style: context.text.caption.copyWith(
                        color: colors.onInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
