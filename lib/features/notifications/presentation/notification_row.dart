import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// One inbox entry (S14, DESIGN §7): the category's tile, or one for its
/// kind, the title, the time on the right and the body. [unread] adds a
/// dot read as "Unread".
class NotificationRow extends StatelessWidget {
  const new({
    required this.notification,
    required this.time,
    required this.unread,
    this.category,
    super.key,
  });

  final AppNotification notification;

  /// "2h", "Yesterday", "3 Nov".
  final String time;
  final bool unread;

  /// The category it's about, when there is one.
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final tile = switch (category) {
      final c? => CategoryTile.forKey(
        c.iconKey,
        color: c.colorKey,
        size: CategoryTileSize.compact,
      ),
      null => CategoryTile(
        icon: _kindIcon(notification.kind),
        color: _kindColour(notification.kind),
        size: CategoryTileSize.compact,
      ),
    };
    return Semantics(
      container: true,
      label: [
        if (unread) l10n.unread,
        notification.title,
        notification.body,
        time,
      ].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r28),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tile,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpreadOrStack(
                    gap: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    start: Text(
                      notification.title,
                      style: text.rowTitle.copyWith(color: colors.ink),
                    ),
                    end: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unread) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.categoryColors
                                  .of(CategoryColorKey.blue)
                                  .icon,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            time,
                            style: text.caption.copyWith(
                              color: colors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: text.body.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AppIcon _kindIcon(NotificationKind kind) => switch (kind) {
  NotificationKind.budgetWarning ||
  NotificationKind.overBudget => AppIcon.warning,
  NotificationKind.dailyReminder => AppIcon.bell,
  NotificationKind.incomeRecorded => AppIcon.wallet,
  NotificationKind.weeklySummary => AppIcon.chartBars,
  NotificationKind.periodStarted => AppIcon.calendar,
};

CategoryColorKey _kindColour(NotificationKind kind) => switch (kind) {
  NotificationKind.budgetWarning => CategoryColorKey.orange,
  NotificationKind.overBudget => CategoryColorKey.red,
  NotificationKind.dailyReminder => CategoryColorKey.purple,
  NotificationKind.incomeRecorded => CategoryColorKey.green,
  NotificationKind.weeklySummary => CategoryColorKey.blue,
  NotificationKind.periodStarted => CategoryColorKey.yellow,
};
