import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/theme/theme_mode_controller.dart';
import 'package:ctrl_spend/features/app_lock/data/channel_secure_window.dart';
import 'package:ctrl_spend/features/app_lock/data/local_device_auth.dart';
import 'package:ctrl_spend/features/app_lock/data/secure_pin_store.dart';
import 'package:ctrl_spend/features/app_lock/domain/device_auth.dart';
import 'package:ctrl_spend/features/app_lock/domain/pin_store.dart';
import 'package:ctrl_spend/features/app_lock/domain/secure_window.dart';
import 'package:ctrl_spend/features/app_lock/presentation/app_lock_gate.dart';
import 'package:ctrl_spend/features/app_lock/presentation/app_switcher_guard.dart';
import 'package:ctrl_spend/features/bills/data/drift_bill_repository.dart';
import 'package:ctrl_spend/features/bills/domain/bill_repository.dart';
import 'package:ctrl_spend/features/categories/data/drift_category_repository.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/data_transfer/data/drift_data_eraser.dart';
import 'package:ctrl_spend/features/data_transfer/data/share_plus_file_sharer.dart';
import 'package:ctrl_spend/features/data_transfer/data/system_csv_file_picker.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_file_picker.dart';
import 'package:ctrl_spend/features/data_transfer/domain/data_eraser.dart';
import 'package:ctrl_spend/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrl_spend/features/goals/data/drift_goal_repository.dart';
import 'package:ctrl_spend/features/goals/domain/goal_repository.dart';
import 'package:ctrl_spend/features/notifications/data/drift_notification_repository.dart';
import 'package:ctrl_spend/features/notifications/data/local_notification_scheduler.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_repository.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_service.dart';
import 'package:ctrl_spend/features/periods/data/drift_period_snapshot_repository.dart';
import 'package:ctrl_spend/features/periods/domain/period_snapshot_repository.dart';
import 'package:ctrl_spend/features/periods/presentation/snapshot_service.dart';
import 'package:ctrl_spend/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/data/drift_transaction_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Poppins'], ofl);
    final isc = await rootBundle.loadString('assets/icons/LICENSE');
    yield LicenseEntryWithLineBreaks(['Lucide'], isc);
  });
  runApp(ProviderScope(overrides: appOverrides(), child: const MainApp()));
}

/// The real implementations behind each repository and platform service.
/// Wired here so screens never import `data/`; the integration tests use
/// them too, with a [scheduler] that doesn't post OS notifications.
List<Override> appOverrides({NotificationScheduler? scheduler}) => [
  categoryRepositoryProvider.overrideWith(
    (ref) => DriftCategoryRepository(ref.watch(appDatabaseProvider)),
  ),
  transactionRepositoryProvider.overrideWith(
    (ref) => DriftTransactionRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  billRepositoryProvider.overrideWith(
    (ref) => DriftBillRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  goalRepositoryProvider.overrideWith(
    (ref) => DriftGoalRepository(ref.watch(appDatabaseProvider)),
  ),
  periodSnapshotRepositoryProvider.overrideWith(
    (ref) => DriftPeriodSnapshotRepository(ref.watch(appDatabaseProvider)),
  ),
  preferencesRepositoryProvider.overrideWith(
    (ref) => DriftPreferencesRepository(ref.watch(appDatabaseProvider)),
  ),
  notificationRepositoryProvider.overrideWith(
    (ref) => DriftNotificationRepository(ref.watch(appDatabaseProvider)),
  ),
  notificationSchedulerProvider.overrideWith(
    (ref) => scheduler ?? LocalNotificationScheduler(),
  ),
  fileSharerProvider.overrideWith((ref) => SharePlusFileSharer()),
  csvFilePickerProvider.overrideWith((ref) => SystemCsvFilePicker()),
  dataEraserProvider.overrideWith(
    (ref) => DriftDataEraser(ref.watch(appDatabaseProvider)),
  ),
  pinStoreProvider.overrideWith((ref) => SecurePinStore()),
  deviceAuthProvider.overrideWith((ref) => LocalDeviceAuth()),
  secureWindowProvider.overrideWith((ref) => ChannelSecureWindow()),
];

class MainApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts scheduling, inbox upkeep and period snapshots for the app's
    // lifetime.
    ref
      ..watch(notificationServiceProvider)
      ..watch(snapshotServiceProvider);
    return MaterialApp.router(
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ref.watch(appThemeModeProvider),
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => AppSwitcherGuard(
        child: AppLockGate(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
