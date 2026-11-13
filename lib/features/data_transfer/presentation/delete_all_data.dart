import 'dart:async';

import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/data_transfer/domain/data_eraser.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_service.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _exportFirst = #exportFirst;

/// Delete all data (S21): asks first, offering Export, then erases
/// everything and cancels scheduled notifications. Settings go back to
/// their defaults, so the router returns to onboarding.
Future<void> confirmAndDeleteAllData(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = context.l10n;
  final choice = await showDialog<Object>(
    context: context,
    builder: (dialogContext) => AppDialog(
      icon: AppIcon.trash,
      title: l10n.deleteAllDataTitle,
      body: l10n.deleteAllDataBody,
      confirmLabel: l10n.deleteEverything,
      destructive: true,
      link: TextLink(
        label: l10n.exportFirst,
        onPressed: () => Navigator.of(dialogContext).pop(_exportFirst),
      ),
    ),
  );
  if (!context.mounted) return;
  if (choice == _exportFirst) {
    unawaited(context.push(Routes.export));
    return;
  }
  if (choice != true) return;
  hideAppToast();
  // Reset first, so nothing reschedules or catches up mid-erase.
  await ref.read(notificationServiceProvider).reset();
  await ref.read(dataEraserProvider).eraseAll();
}
