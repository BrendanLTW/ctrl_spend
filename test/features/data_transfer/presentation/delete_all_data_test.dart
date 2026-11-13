import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/export_screen.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_service.dart';
import 'package:ctrl_spend/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_data_eraser.dart';
import '../../../helpers/fake_notification_repository.dart';
import '../../../helpers/fake_notification_scheduler.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fake_transaction_repository.dart';

late FakePreferencesRepository prefs;
late FakeCategoryRepository categories;
late FakeTransactionRepository transactions;
late FakeNotificationRepository inbox;
late FakeNotificationScheduler scheduler;
late FakeDataEraser eraser;
late ProviderContainer container;

Future<void> pumpSettings(
  WidgetTester tester, {
  AppTheme theme = AppTheme.system,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  prefs = FakePreferencesRepository(
    Preferences(
      userName: 'Alex',
      onboardingComplete: true,
      monthStartDay: const DayOfMonth(15),
      monthlyBudgetMinor: 200000,
      theme: theme,
    ),
  );
  categories = FakeCategoryRepository();
  transactions = FakeTransactionRepository();
  inbox = FakeNotificationRepository();
  scheduler = FakeNotificationScheduler();
  eraser = FakeDataEraser(
    preferences: prefs,
    categories: categories,
    transactions: transactions,
    inbox: inbox,
  );
  await categories.update(
    categories.byName('Food').copyWith(limitMinor: 40000),
  );
  await transactions.add(
    amountMinor: 1250,
    type: TransactionType.expense,
    categoryId: categories.byName('Food').id,
    occurredAt: DateTime(2026, 11, 4, 8),
    title: 'Nasi lemak',
  );
  await inbox.add(
    kind: NotificationKind.dailyReminder,
    title: 'Daily reminder',
    body: 'x',
    createdAt: DateTime(2026, 11, 3, 21),
  );
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: prefs,
        categories: categories,
        transactions: transactions,
        notifications: inbox,
        scheduler: scheduler,
        eraser: eraser,
      ),
      clockProvider.overrideWithValue(() => DateTime(2026, 11, 4, 9)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  unawaited(container.read(appRouterProvider).push(Routes.settings));
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> openDialog(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.text('Delete all data'), 200);
  await tap(tester, 'Delete all data');
}

void main() {
  testWidgets('Settings has the row and the dialog explains it', (
    tester,
  ) async {
    await pumpSettings(tester);
    await openDialog(tester);
    expect(find.byType(AppDialog), findsOneWidget);
    expect(find.text('Delete all data?'), findsOneWidget);
    expect(
      find.text(
        'This erases every transaction, category, notification and setting '
        "on this phone. It can't be undone.",
      ),
      findsOneWidget,
    );
    expect(find.text('Export first'), findsOneWidget);
    expect(find.text('Delete everything'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Cancel keeps everything', (tester) async {
    await pumpSettings(tester);
    await openDialog(tester);
    await tap(tester, 'Cancel');
    expect(eraser.erased, 0);
    expect(transactions.all, hasLength(1));
    expect(find.byType(AppDialog), findsNothing);
  });

  testWidgets('Export first opens S35 and deletes nothing', (tester) async {
    await pumpSettings(tester);
    await openDialog(tester);
    await tap(tester, 'Export first');
    expect(find.byType(ExportScreen), findsOneWidget);
    expect(eraser.erased, 0);
    expect(transactions.all, hasLength(1));
  });

  testWidgets('Delete everything erases it all and restarts onboarding', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(scheduler.pending, isNotEmpty);
    await openDialog(tester);
    await tap(tester, 'Delete everything');
    expect(eraser.erased, 1);
    expect(transactions.all, isEmpty);
    expect(inbox.all, isEmpty);
    expect(categories.byName('Food').limitMinor, isNull);
    expect(await prefs.read(), const Preferences());
    expect(scheduler.pending, isEmpty);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('finishing onboarding again schedules from scratch', (
    tester,
  ) async {
    await pumpSettings(tester);
    await openDialog(tester);
    await tap(tester, 'Delete everything');
    await prefs.update((p) => p.copyWith(onboardingComplete: true));
    await tester.pumpAndSettle();
    expect(scheduler.pending[NotificationService.dailyId]?.kind, 'daily');
    expect(scheduler.pending[NotificationService.periodId], isNotNull);
    expect((await prefs.read()).notificationsCheckedAt, isNotNull);
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('the row is red in ${theme.name} mode', (tester) async {
      await pumpSettings(tester, theme: theme);
      final row = tester.widget<ListGroupRow>(
        find.byWidgetPredicate(
          (w) => w is ListGroupRow && w.title == 'Delete all data',
        ),
      );
      expect(row.titleColor, colors.negative);
    });
  }
}
