import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/theme/theme_mode_controller.dart';
import 'package:ctrl_spend/features/categories/data/drift_category_repository.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/data_transfer/data/share_plus_file_sharer.dart';
import 'package:ctrl_spend/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrl_spend/features/notifications/data/drift_notification_repository.dart';
import 'package:ctrl_spend/features/notifications/data/local_notification_scheduler.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_repository.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_service.dart';
import 'package:ctrl_spend/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/data/drift_transaction_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Poppins'], ofl);
  });
  runApp(
    ProviderScope(
      // Repository implementations are wired here so screens never import
      // `data/`.
      overrides: [
        categoryRepositoryProvider.overrideWith(
          (ref) => DriftCategoryRepository(ref.watch(appDatabaseProvider)),
        ),
        transactionRepositoryProvider.overrideWith(
          (ref) => DriftTransactionRepository(ref.watch(appDatabaseProvider)),
        ),
        preferencesRepositoryProvider.overrideWith(
          (ref) => DriftPreferencesRepository(ref.watch(appDatabaseProvider)),
        ),
        notificationRepositoryProvider.overrideWith(
          (ref) => DriftNotificationRepository(ref.watch(appDatabaseProvider)),
        ),
        notificationSchedulerProvider.overrideWith(
          (ref) => LocalNotificationScheduler(),
        ),
        fileSharerProvider.overrideWith((ref) => SharePlusFileSharer()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts scheduling and inbox upkeep for the app's lifetime.
    ref.watch(notificationServiceProvider);
    return MaterialApp.router(
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ref.watch(appThemeModeProvider),
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
