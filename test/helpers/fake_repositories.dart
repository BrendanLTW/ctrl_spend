import 'package:ctrlspend/core/app/app_version.dart';
import 'package:ctrlspend/features/app_lock/domain/device_auth.dart';
import 'package:ctrlspend/features/app_lock/domain/pin_store.dart';
import 'package:ctrlspend/features/app_lock/domain/secure_window.dart';
import 'package:ctrlspend/features/bills/domain/bill_repository.dart';

import 'package:ctrlspend/features/categories/domain/category_repository.dart';
import 'package:ctrlspend/features/data_transfer/domain/csv_file_picker.dart';
import 'package:ctrlspend/features/data_transfer/domain/data_eraser.dart';
import 'package:ctrlspend/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrlspend/features/goals/domain/goal_repository.dart';
import 'package:ctrlspend/features/notifications/domain/notification_repository.dart';
import 'package:ctrlspend/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrlspend/features/periods/domain/period_snapshot_repository.dart';
import 'package:ctrlspend/features/settings/domain/preferences_repository.dart';
import 'package:ctrlspend/features/transactions/domain/transaction_repository.dart';
import 'package:flutter_riverpod/misc.dart';

import 'fake_app_lock.dart';
import 'fake_bill_repository.dart';
import 'fake_category_repository.dart';
import 'fake_csv_file_picker.dart';
import 'fake_data_eraser.dart';
import 'fake_file_sharer.dart';
import 'fake_goal_repository.dart';
import 'fake_notification_repository.dart';
import 'fake_notification_scheduler.dart';
import 'fake_period_snapshot_repository.dart';
import 'fake_preferences_repository.dart';
import 'fake_transaction_repository.dart';

/// Overrides every repository with an in-memory fake, so a test that
/// builds the whole app needs only pass the ones it inspects.
List<Override> fakeRepositories({
  PreferencesRepository? preferences,
  CategoryRepository? categories,
  TransactionRepository? transactions,
  BillRepository? bills,
  GoalRepository? goals,
  PeriodSnapshotRepository? snapshots,
  NotificationRepository? notifications,
  NotificationScheduler? scheduler,
  FileSharer? sharer,
  CsvFilePicker? picker,
  DataEraser? eraser,
  PinStore? pin,
  DeviceAuth? deviceAuth,
  SecureWindow? secureWindow,
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
  billRepositoryProvider.overrideWithValue(bills ?? FakeBillRepository()),
  goalRepositoryProvider.overrideWithValue(goals ?? FakeGoalRepository()),
  periodSnapshotRepositoryProvider.overrideWithValue(
    snapshots ?? FakePeriodSnapshotRepository(),
  ),
  notificationRepositoryProvider.overrideWithValue(
    notifications ?? FakeNotificationRepository(),
  ),
  notificationSchedulerProvider.overrideWithValue(
    scheduler ?? FakeNotificationScheduler(),
  ),
  fileSharerProvider.overrideWithValue(sharer ?? FakeFileSharer()),
  csvFilePickerProvider.overrideWithValue(picker ?? FakeCsvFilePicker()),
  dataEraserProvider.overrideWithValue(eraser ?? FakeDataEraser()),
  appVersionProvider.overrideWith((_) async => '1.0.0'),
  pinStoreProvider.overrideWithValue(pin ?? FakePinStore()),
  deviceAuthProvider.overrideWithValue(deviceAuth ?? FakeDeviceAuth()),
  secureWindowProvider.overrideWithValue(secureWindow ?? FakeSecureWindow()),
];
