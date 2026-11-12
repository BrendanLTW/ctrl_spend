import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_repository.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:flutter_riverpod/misc.dart';

import 'fake_category_repository.dart';
import 'fake_file_sharer.dart';
import 'fake_notification_repository.dart';
import 'fake_notification_scheduler.dart';
import 'fake_preferences_repository.dart';
import 'fake_transaction_repository.dart';

/// Overrides every repository with an in-memory fake, so a test that
/// builds the whole app needs only pass the ones it inspects.
List<Override> fakeRepositories({
  PreferencesRepository? preferences,
  CategoryRepository? categories,
  TransactionRepository? transactions,
  NotificationRepository? notifications,
  NotificationScheduler? scheduler,
  FileSharer? sharer,
}) => [
  preferencesRepositoryProvider.overrideWithValue(
    preferences ?? FakePreferencesRepository(),
  ),
  categoryRepositoryProvider.overrideWithValue(
    categories ?? FakeCategoryRepository(),
  ),
  transactionRepositoryProvider.overrideWithValue(
    transactions ?? FakeTransactionRepository(),
  ),
  notificationRepositoryProvider.overrideWithValue(
    notifications ?? FakeNotificationRepository(),
  ),
  notificationSchedulerProvider.overrideWithValue(
    scheduler ?? FakeNotificationScheduler(),
  ),
  fileSharerProvider.overrideWithValue(sharer ?? FakeFileSharer()),
];
