import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/app_typography.dart';
import 'package:ctrlspend/core/widgets/large_text.dart';
import 'package:flutter/material.dart';

/// An S27 row in a `ListGroup`: tile, name, a coloured due or paid line,
/// and the amount, then an optional [action] such as the Pay pill, which
/// stays its own button. With large text the amount goes under the name.
/// S56's history rows have no tile.
class BillRow extends StatelessWidget {
  const new({
    required this.title,
    required this.caption,
    required this.captionColor,
    required this.amount,
    this.tile,
    this.action,
    this.onTap,
    super.key,
  });

  final Widget? tile;
  final Widget? action;
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
    final row = Semantics(
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
            padding: EdgeInsets.fromLTRB(18, 10, action == null ? 18 : 10, 10),
            child: Row(
              children: [
                if (tile case final tile?) ...[tile, const SizedBox(width: 16)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: text.rowTitle.copyWith(color: colors.ink),
                        // Two lines beside the Pay pill, as designed.
                        maxLines: stacked ? null : 2,
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
    if (action case final action?) {
      return Row(
        children: [
          Expanded(child: row),
          Padding(padding: const EdgeInsets.only(right: 12), child: action),
        ],
      );
    }
    return row;
  }
}
