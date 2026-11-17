import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/features/app_lock/domain/pin_store.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The four PIN dots (S38, S64): 16 px rings, filled as digits go in,
/// red when [error].
class PinDots extends StatelessWidget {
  const new({required this.count, this.error = false, super.key});

  final int count;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: context.l10n.pinDotsLabel(count),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < pinLength; i++) ...[
            if (i > 0) const SizedBox(width: 18),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < count ? colors.ink : Colors.transparent,
                border: Border.all(
                  color: error
                      ? colors.negative
                      : i < count
                      ? colors.ink
                      : colors.muted,
                  width: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The PIN pad (S38, S64): 1–9, then [extra] (S38's biometric key, or
/// nothing), 0 and backspace. 64 px keys, radius 20. [enabled] false dims
/// the digits (S66); [extra] stays active.
class PinPad extends StatelessWidget {
  const new({
    required this.onDigit,
    required this.onBackspace,
    this.extra,
    this.enabled = true,
    super.key,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final Widget? extra;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget key(Widget child, VoidCallback onTap, {bool plain = false}) =>
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Material(
              color: plain ? Colors.transparent : colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: enabled ? onTap : null,
                highlightColor: colors.raised,
                splashFactory: NoSplash.splashFactory,
                child: SizedBox(height: 64, child: Center(child: child)),
              ),
            ),
          ),
        );
    Widget digit(int d) => key(
      Text(
        '$d',
        style: context.text.pinKey.copyWith(
          color: enabled ? colors.ink : colors.disabled,
        ),
      ),
      () => onDigit(d),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(children: [for (final d in row) digit(d)]),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: SizedBox(height: 64, child: extra),
              ),
            ),
            digit(0),
            key(
              Semantics(
                label: context.l10n.keypadBackspace,
                button: true,
                excludeSemantics: true,
                child: AppIconView(
                  AppIcon.backspace,
                  size: 26,
                  color: enabled ? colors.ink : colors.disabled,
                ),
              ),
              onBackspace,
              plain: true,
            ),
          ],
        ),
      ],
    );
  }
}
