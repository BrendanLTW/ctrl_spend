import 'dart:async';

import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/widgets/app_dialog.dart';
import 'package:ctrlspend/core/widgets/app_icon.dart';
import 'package:ctrlspend/core/widgets/app_toast.dart';
import 'package:ctrlspend/core/widgets/text_link.dart';
import 'package:ctrlspend/features/app_lock/domain/pin_store.dart';
import 'package:ctrlspend/features/data_transfer/domain/data_eraser.dart';
import 'package:ctrlspend/features/notifications/presentation/notification_service.dart';
import 'package:ctrlspend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrlspend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _exportFirst = #exportFirst;

/// S49 Erase all data: asks first, offering "Export a CSV first" unless
/// [offerExport] is false (from the lock screen's S67), then erases
/// everything, the app lock PIN too, cancels scheduled notifications and
/// restarts at the splash screen (S01), which moves on to onboarding.
Future<void> confirmAndDeleteAllData(
  BuildContext context,
  WidgetRef ref, {
  bool offerExport = true,
}) async {
  final l10n = context.l10n;
  final count = (await ref.read(transactionsProvider().future)).length;
  if (!context.mounted) return;
  final choice = await showDialog<Object>(
    barrierColor: context.colors.scrim,
    context: context,
    builder: (dialogContext) => AppDialog(
      layout: AppDialogLayout.state,
      icon: AppIcon.trash,
      title: l10n.eraseAllDataTitle,
      body: l10n.eraseAllDataBody(count),
      confirmLabel: l10n.eraseEverything,
      destructive: true,
      link: offerExport
          ? TextLink(
              label: l10n.exportCsvFirst,
              underline: true,
              onPressed: () => Navigator.of(dialogContext).pop(_exportFirst),
            )
          : null,
    ),
  );
  if (!context.mounted) return;
  if (choice == _exportFirst) {
    unawaited(context.push(Routes.export));
    return;
  }
  if (choice != true) return;
  hideAppToast();
  final router = ref.read(appRouterProvider);
  // Reset first, so nothing reschedules or catches up mid-erase.
  await ref.read(notificationServiceProvider).reset();
  await ref.read(dataEraserProvider).eraseAll();
  await ref.read(pinStoreProvider).clear();
  router.go(Routes.splash);
}
