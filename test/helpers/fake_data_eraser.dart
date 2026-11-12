import 'package:ctrl_spend/features/data_transfer/domain/data_eraser.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';

import 'fake_category_repository.dart';
import 'fake_notification_repository.dart';
import 'fake_preferences_repository.dart';
import 'fake_transaction_repository.dart';

/// Erases the in-memory fakes it's given, as the real eraser does the
/// database. With none given, it only counts calls.
class FakeDataEraser implements DataEraser {
  new({this.preferences, this.categories, this.transactions, this.inbox});

  final FakePreferencesRepository? preferences;
  final FakeCategoryRepository? categories;
  final FakeTransactionRepository? transactions;
  final FakeNotificationRepository? inbox;
  int erased = 0;

  @override
  Future<void> eraseAll() async {
    erased++;
    transactions?.clear();
    inbox?.clear();
    categories?.reset();
    await preferences?.update((_) => const Preferences());
  }
}
