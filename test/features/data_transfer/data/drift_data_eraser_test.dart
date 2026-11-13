import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/categories/data/drift_category_repository.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/data/drift_data_eraser.dart';
import 'package:ctrl_spend/features/notifications/data/drift_notification_repository.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/data/drift_transaction_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('leaves the app as a fresh install would be', () async {
    final categories = DriftCategoryRepository(db);
    final transactions = DriftTransactionRepository(db);
    final prefs = DriftPreferencesRepository(db);
    final defaults = [
      for (final c in await categories.watch().first) (c.name, c.type),
    ];

    final pets = await categories.add(
      name: 'Pets',
      type: TransactionType.expense,
      iconKey: CategoryIconKey.heart,
      colorKey: CategoryColorKey.purple,
      limitMinor: 10000,
    );
    await transactions.add(
      amountMinor: 1250,
      type: TransactionType.expense,
      categoryId: pets.id,
      occurredAt: DateTime(2026, 11, 4),
      title: 'Food',
    );
    await DriftNotificationRepository(db).add(
      kind: NotificationKind.overBudget,
      title: 'Pets is over budget',
      body: 'x',
      createdAt: DateTime(2026, 11, 4),
      categoryId: pets.id,
    );
    await prefs.update(
      (p) => p.copyWith(
        userName: 'Alex',
        monthlyBudgetMinor: 200000,
        onboardingComplete: true,
        theme: AppTheme.dark,
      ),
    );

    await DriftDataEraser(db).eraseAll();

    expect(await transactions.watch().first, isEmpty);
    expect(await DriftNotificationRepository(db).watch().first, isEmpty);
    expect(await prefs.read(), const Preferences());
    final after = await categories.watch().first;
    expect([for (final c in after) (c.name, c.type)], defaults);
    expect(after.every((c) => c.limitMinor == null && !c.archived), isTrue);
  });
}
