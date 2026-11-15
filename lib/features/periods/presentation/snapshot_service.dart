import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/periods/domain/period_snapshot.dart';
import 'package:ctrl_spend/features/periods/domain/period_snapshot_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'snapshot_service.g.dart';

/// Saves a snapshot of each period that has ended (PRD §6.2), once
/// everything has loaded on launch, and again on each resume: the app
/// can't run code at the moment a period ends.
class SnapshotService {
  new(this._ref) {
    _ref
      ..listen(preferencesProvider, (_, next) {
        _prefs = next.value ?? _prefs;
        _onLoaded();
      }, fireImmediately: true)
      ..listen(categoriesProvider(), (_, next) {
        _categories = next.value ?? _categories;
        _onLoaded();
      }, fireImmediately: true)
      ..listen(transactionsProvider(), (_, next) {
        _transactions = next.value ?? _transactions;
        _onLoaded();
      }, fireImmediately: true)
      ..listen(periodSnapshotsProvider, (_, next) {
        _snapshots = next.value ?? _snapshots;
        _onLoaded();
      }, fireImmediately: true);
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(write()));
  }

  final Ref _ref;
  late final AppLifecycleListener _lifecycle;

  Preferences? _prefs;
  List<Category>? _categories;
  List<Transaction>? _transactions;
  List<PeriodSnapshot>? _snapshots;
  bool _wroteOnLaunch = false;
  Future<void>? _writing;

  /// Saves the snapshots that are due, if everything has loaded and
  /// onboarding is done.
  Future<void> write() => _writing ??= () async {
    try {
      final prefs = _prefs;
      final categories = _categories;
      final transactions = _transactions;
      final snapshots = _snapshots;
      if (prefs == null ||
          !prefs.onboardingComplete ||
          categories == null ||
          transactions == null ||
          snapshots == null) {
        return;
      }
      final due = snapshotsToWrite(
        existing: snapshots,
        transactions: transactions,
        categories: categories,
        today: _ref.read(clockProvider)(),
        startDay: prefs.monthStartDay,
        budgetMinor: prefs.monthlyBudgetMinor,
      );
      if (due.isNotEmpty) {
        await _ref.read(periodSnapshotRepositoryProvider).addAll(due);
      }
    } finally {
      _writing = null;
    }
  }();

  void _onLoaded() {
    if (_wroteOnLaunch ||
        _prefs?.onboardingComplete != true ||
        _categories == null ||
        _transactions == null ||
        _snapshots == null) {
      return;
    }
    _wroteOnLaunch = true;
    unawaited(write());
  }

  void dispose() => _lifecycle.dispose();
}

@Riverpod(keepAlive: true)
SnapshotService snapshotService(Ref ref) {
  final service = SnapshotService(ref);
  ref.onDispose(service.dispose);
  return service;
}
