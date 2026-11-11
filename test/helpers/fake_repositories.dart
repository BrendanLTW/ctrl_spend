import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:flutter_riverpod/misc.dart';

import 'fake_category_repository.dart';
import 'fake_preferences_repository.dart';
import 'fake_transaction_repository.dart';

/// Overrides every repository with an in-memory fake, so a test that
/// builds the whole app needs only pass the ones it inspects.
List<Override> fakeRepositories({
  PreferencesRepository? preferences,
  CategoryRepository? categories,
  TransactionRepository? transactions,
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
];
