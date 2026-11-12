import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_repository.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_row.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_settings_sheet.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:ctrl_spend/l10n/setting_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S14 Notifications, grouped Today and Earlier, or S15 when there are
/// none. Opening it marks everything read, which clears the bell; the
/// rows that were unread keep their dot for this visit.
class NotificationsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  /// What was unread when the screen opened; null until the inbox loads.
  Set<int>? _unreadOnOpen;

  void _markRead(List<AppNotification> all) {
    final unread = {
      for (final n in all)
        if (n.readAt == null) n.id,
    };
    _unreadOnOpen = unread;
    if (unread.isEmpty) return;
    final now = ref.read(clockProvider)();
    // After this frame, so the dots draw before the rows turn read.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(notificationRepositoryProvider).markAllRead(now),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final all = ref.watch(notificationsProvider).value;
    if (all != null && _unreadOnOpen == null) _markRead(all);
    final today = ref.watch(clockProvider)();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final categories = {
      for (final c
          in ref.watch(categoriesProvider()).value ?? const <Category>[])
        c.id: c,
    };

    bool isToday(DateTime at) => DateUtils.isSameDay(at.toLocal(), today);
    Widget row(AppNotification n) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: NotificationRow(
        notification: n,
        time: _timeLabel(l10n, n.createdAt.toLocal(), today, locale),
        unread: _unreadOnOpen?.contains(n.id) ?? false,
        category: categories[n.categoryId],
      ),
    );

    final list = all ?? const <AppNotification>[];
    final todays = [
      for (final n in list)
        if (isToday(n.createdAt)) n,
    ];
    final earlier = [
      for (final n in list)
        if (!isToday(n.createdAt)) n,
    ];

    return Scaffold(
      backgroundColor: colors.ground,
      appBar: AppBar(
        backgroundColor: colors.ground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const AppIconView(
            AppIcon.chevronLeft,
            stroke: AppIconStroke.chevron,
            size: 30,
          ),
          color: colors.ink,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.notifications,
          style: text.header.copyWith(color: colors.ink),
        ),
        actions: [
          IconButton(
            tooltip: l10n.notificationSettings,
            icon: const AppIconView(AppIcon.sliders, size: 24),
            color: colors.ink,
            onPressed: () => showNotificationSettingsSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: all == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                8,
                AppSpacing.screenX,
                32,
              ),
              children: [
                if (list.isEmpty) const _Empty(),
                if (todays.isNotEmpty) ...[
                  SectionLabel(l10n.today),
                  for (final n in todays) row(n),
                  const SizedBox(height: AppSpacing.sectionTop - 12),
                ],
                if (earlier.isNotEmpty) ...[
                  SectionLabel(l10n.earlierSection),
                  for (final n in earlier) row(n),
                ],
              ],
            ),
    );
  }
}

/// "now", "12m" or "2h" today; "Yesterday"; then "3 Nov".
String _timeLabel(
  AppLocalizations l10n,
  DateTime at,
  DateTime now,
  String locale,
) {
  final day = DateTime.utc(at.year, at.month, at.day);
  final today = DateTime.utc(now.year, now.month, now.day);
  return switch (today.difference(day).inDays) {
    0 => switch (now.difference(at)) {
      final d when d.inMinutes < 1 => l10n.notificationNow,
      final d when d.inHours < 1 => l10n.minutesAgo(d.inMinutes),
      final d => l10n.hoursAgo(d.inHours),
    },
    1 => l10n.yesterday,
    _ => DateFormat('d MMM', locale).format(at),
  };
}

/// S15: no notifications yet, and which kinds are on.
class _Empty extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    String onOff({required bool on}) => on ? l10n.onLabel : l10n.offLabel;
    void open() => unawaited(showNotificationSettingsSheet(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        EmptyState(
          card: false,
          icon: AppIcon.bell,
          title: l10n.noNotificationsTitle,
          body: l10n.noNotificationsBody,
        ),
        const SizedBox(height: 32),
        SectionLabel(l10n.youllHearAbout),
        ListGroup(
          children: [
            ListGroupRow(
              leading: const CategoryTile(
                icon: AppIcon.warning,
                color: CategoryColorKey.orange,
              ),
              title: l10n.budgetAlerts,
              subtitle: l10n.at80And100,
              value: onOff(on: prefs.budgetAlertsOn),
              onTap: open,
            ),
            ListGroupRow(
              leading: const CategoryTile(
                icon: AppIcon.clock,
                color: CategoryColorKey.purple,
              ),
              title: l10n.dailyReminder,
              subtitle: l10n.dailyReminderAt(
                l10n.reminderTime(prefs.dailyReminderMinutes, locale),
              ),
              value: onOff(on: prefs.dailyReminderOn),
              onTap: open,
            ),
            ListGroupRow(
              leading: const CategoryTile(
                icon: AppIcon.chartBars,
                color: CategoryColorKey.blue,
              ),
              title: l10n.weeklySummary,
              subtitle: l10n.weeklySummaryDetail,
              value: onOff(on: prefs.weeklySummaryOn),
              onTap: open,
            ),
          ],
        ),
      ],
    );
  }
}
