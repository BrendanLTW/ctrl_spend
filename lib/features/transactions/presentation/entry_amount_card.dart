import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The amount on S12, S13 and S45 (DESIGN §6): "TOTAL AMOUNT", then the
/// amount in `amountEntry` with a smaller "RM" and cents, and a caret
/// after it. Empty, it reads a muted "RM 0.00". Income shows in
/// `positive`. Typed with the keypad pinned below, so it isn't a button.
class EntryAmountCard extends StatelessWidget {
  const new({
    required this.minor,
    required this.currency,
    required this.income,
    super.key,
  });

  final int minor;
  final Currency currency;
  final bool income;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final formatter = MoneyFormatter(currency);
    final (:head, :cents) = formatter.split(minor);
    final digits = head.substring(currency.symbol.length + 1);
    final colour = minor == 0
        ? colors.disabled
        : income
        ? colors.positive
        : colors.ink;
    final small = text.stateTitle.copyWith(color: colour);
    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.totalAmountLabel(formatter.format(minor)),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r28),
        ),
        child: Column(
          children: [
            Text(
              l10n.totalAmount.toUpperCase(),
              style: text.label.copyWith(color: colors.muted),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(currency.symbol, style: small),
                  const SizedBox(width: 8),
                  Text(digits, style: text.amountEntry.copyWith(color: colour)),
                  Text(cents, style: small.copyWith(color: colors.muted)),
                  const SizedBox(width: 4),
                  // The caret: the keypad is always typing here.
                  Container(width: 2, height: 44, color: colors.ink),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
