import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter/material.dart';

/// A transaction in a list (DESIGN §7): tile, title, caption and a signed
/// amount coloured by type. The caller writes the caption, since screens
/// differ ("Today · Food" on Home, "Food" in Activity).
class TransactionRow extends StatelessWidget {
  const new({
    required this.title,
    required this.caption,
    required this.amountMinor,
    required this.type,
    required this.currency,
    this.tile,
    this.compact = false,
    this.onTap,
    super.key,
  });

  /// Usually a [CategoryTile] sized to match [compact]. Left out where
  /// the category is already known (S23's Recent).
  final Widget? tile;
  final String title;
  final String caption;
  final int amountMinor;
  final TransactionType type;
  final Currency currency;

  /// Activity's denser row, with the 44 px tile and 15 px titles.
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final amount = MoneyFormatter(currency).format(
      amountMinor,
      sign: type == TransactionType.expense
          ? MoneySign.expense
          : MoneySign.income,
    );
    return Semantics(
      button: onTap != null,
      label: '$title, $caption, $amount',
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(
          compact ? AppRadius.r24 - 2 : AppRadius.r24,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: compact ? 66 : 72),
            child: Padding(
              padding: EdgeInsets.fromLTRB(tile == null ? 18 : 12, 12, 18, 12),
              child: Row(
                children: [
                  if (tile case final tile?) ...[
                    tile,
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: (compact ? text.rowTitleSm : text.rowTitle)
                              .copyWith(color: colors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          caption,
                          style: text.caption.copyWith(color: colors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    amount,
                    style: text.amountRow.copyWith(
                      color: type == TransactionType.expense
                          ? colors.negative
                          : colors.positive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
