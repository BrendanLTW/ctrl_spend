import 'package:ctrl_spend/core/money/amount_input.dart';
import 'package:ctrl_spend/core/widgets/money_keypad_key.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum MoneyKeypadSize {
  /// Onboarding and other full screens: 56 high, `surface` keys.
  full,

  /// Inside bottom sheets: 48 high, `fillSoft` keys.
  sheet,
}

/// The 3x4 money keypad (PRD §6.1, DESIGN §7). Controlled: it reports the
/// next amount in minor units through [onChanged] and holds no state.
class MoneyKeypad extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    this.size = MoneyKeypadSize.full,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final MoneyKeypadSize size;

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget key(KeypadKey k) {
      void press() {
        final next = applyKey(value, k);
        if (next != value) onChanged(next);
      }

      return Expanded(
        child: switch (k) {
          DigitKey(:final digit) => MoneyKeypadKey(
            size: size,
            text: '$digit',
            onTap: press,
          ),
          DoubleZeroKey() => MoneyKeypadKey(
            size: size,
            text: '00',
            semanticLabel: l10n.keypadDoubleZero,
            onTap: press,
          ),
          // shortcut: Material icon stands in for the designs' backspace
          // glyph; swap for the AppIcon set once the SVGs are exported.
          BackspaceKey() => MoneyKeypadKey(
            size: size,
            icon: Icons.backspace_outlined,
            semanticLabel: l10n.keypadBackspace,
            onTap: press,
          ),
        },
      );
    }

    const rows = [
      [DigitKey(1), DigitKey(2), DigitKey(3)],
      [DigitKey(4), DigitKey(5), DigitKey(6)],
      [DigitKey(7), DigitKey(8), DigitKey(9)],
      [DoubleZeroKey(), DigitKey(0), BackspaceKey()],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _gap,
      children: [
        for (final row in rows)
          Row(spacing: _gap, children: [for (final k in row) key(k)]),
      ],
    );
  }
}
