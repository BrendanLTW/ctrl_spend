import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:flutter/material.dart';

/// An S27 row in a `ListGroup`: tile, name, a coloured due or paid line,
/// and the amount. With large text the amount goes under the name.
class BillRow extends StatelessWidget {
  const new({
    required this.tile,
    required this.title,
    required this.caption,
    required this.captionColor,
    required this.amount,
    this.onTap,
    super.key,
  });

  final Widget tile;
  final String title;
  final String caption;
  final Color captionColor;

  /// Formatted, without a sign: a bill is always money out.
  final String amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final stacked = largeText(context);
    final amountText = Text(
      amount,
      style: text.amountRow.copyWith(color: colors.ink),
    );
    return Semantics(
      button: onTap != null,
      label: '$title, $caption, $amount',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
            child: Row(
              children: [
                tile,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: text.rowTitle.copyWith(color: colors.ink),
                        maxLines: stacked ? null : 1,
                        overflow: stacked ? null : TextOverflow.ellipsis,
                      ),
                      Text(
                        caption,
                        style: text.caption.copyWith(color: captionColor),
                      ),
                      if (stacked) amountText,
                    ],
                  ),
                ),
                if (!stacked) ...[const SizedBox(width: 12), amountText],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
