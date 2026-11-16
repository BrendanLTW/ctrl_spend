import 'dart:async';

import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/message_box.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrl_spend/features/notifications/presentation/reminder_time_sheet.dart';
import 'package:ctrl_spend/features/notifications/presentation/reminder_toggles.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:ctrl_spend/l10n/setting_labels.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S48 Notification settings: reminders, alerts and summaries, saved as
/// they change. When the phone has notifications off, a banner explains
/// it and opens the phone's Settings; the toggles still save. Bill
/// reminders (v1.1) show in debug builds until task 5.9.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from the phone's Settings: check the permission again.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationsPermittedProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final permitted = ref.watch(notificationsPermittedProvider).value ?? true;
    void save(Preferences Function(Preferences) change) =>
        unawaited(ref.read(preferencesRepositoryProvider).update(change));

    Future<void> pickTime() async {
      final minutes = await showReminderTimeSheet(
        context,
        minutes: prefs.dailyReminderMinutes,
      );
      if (minutes != null) {
        save((p) => p.copyWith(dailyReminderMinutes: minutes));
      }
    }

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
          l10n.notificationsRow,
          style: text.header.copyWith(color: colors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          4,
          AppSpacing.screenX,
          32,
        ),
        children: [
          if (!permitted)
            _PermissionBanner(
              onOpenSettings: () => unawaited(
                ref.read(notificationSchedulerProvider).openSystemSettings(),
              ),
            ),
          SectionLabel(l10n.remindersSection),
          ListGroup(
            children: [
              ToggleRow(
                title: l10n.dailyReminder,
                detail: l10n.dailyReminderDetail,
                value: prefs.dailyReminderOn,
                onChanged: (on) => save((p) => p.copyWith(dailyReminderOn: on)),
              ),
              ListGroupRow(
                title: l10n.remindMeAt,
                value: l10n.reminderTime(prefs.dailyReminderMinutes, locale),
                onTap: pickTime,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionTop),
          SectionLabel(l10n.alertsSection),
          ListGroup(
            children: [
              ToggleRow(
                title: l10n.budgetAlerts,
                detail: l10n.budgetAlertsDetail,
                value: prefs.budgetAlertsOn,
                onChanged: (on) => save((p) => p.copyWith(budgetAlertsOn: on)),
              ),
              ToggleRow(
                title: l10n.weeklySummary,
                detail: l10n.weeklySummaryDetail,
                value: prefs.weeklySummaryOn,
                onChanged: (on) => save((p) => p.copyWith(weeklySummaryOn: on)),
              ),
              if (kDebugMode)
                ToggleRow(
                  title: l10n.billReminders,
                  detail: l10n.billRemindersDetail,
                  value: prefs.billRemindersOn,
                  onChanged: (on) =>
                      save((p) => p.copyWith(billRemindersOn: on)),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: Text(
              l10n.notificationsFootnote,
              style: text.caption.copyWith(color: colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Notifications are off for ctrlSpend", with Open phone settings.
class _PermissionBanner extends StatelessWidget {
  const new({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final style = context.text.message.copyWith(color: colors.onWarningBox);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MessageBox(
        '${l10n.notificationsOffTitle}. ${l10n.notificationsOffBody}',
        kind: MessageKind.warning,
        action: Semantics(
          container: true,
          button: true,
          child: InkWell(
            onTap: onOpenSettings,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: Text(
                  l10n.openPhoneSettings,
                  style: style.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.onWarningBox,
                  ),
                ),
              ),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationsOffTitle,
              style: style.copyWith(
                fontSize: context.text.navLabel.fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(l10n.notificationsOffBody, style: style),
          ],
        ),
      ),
    );
  }
}
