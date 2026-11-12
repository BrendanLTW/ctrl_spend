import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/features/notifications/presentation/reminder_toggles.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Notification preferences (PRD §5.4 "A settings icon opens notification
/// preferences"): S07's three toggles, saved as they change.
Future<void> showNotificationSettingsSheet(BuildContext context) =>
    showAppSheet<void>(
      context,
      title: context.l10n.notificationSettings,
      builder: (_) => const ReminderToggles(),
    );
