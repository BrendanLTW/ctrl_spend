import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/periods/presentation/past_periods_screen.dart';
import 'package:ctrl_spend/features/periods/presentation/period_detail_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fake_transaction_repository.dart';

/// 4 Nov 2026; with start day 15 the period is 15 Oct – 14 Nov.
final now = DateTime(2026, 11, 4, 9);

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpApp(
  WidgetTester tester, {
  required String location,
  int? budget = 200000,
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed = designHistory,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  transactions = FakeTransactionRepository();
  categories = FakeCategoryRepository();
  await seed?.call();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: FakePreferencesRepository(
          Preferences(
            onboardingComplete: true,
            monthStartDay: const DayOfMonth(15),
            monthlyBudgetMinor: budget,
            theme: theme,
          ),
        ),
        categories: categories,
        transactions: transactions,
      ),
      clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  // push() completes only when the screen closes, so don't wait for it.
  unawaited(container.read(appRouterProvider).push(location));
  await tester.pumpAndSettle();
}

Future<void> spend(int minor, String category, DateTime at) => transactions.add(
  amountMinor: minor,
  type: TransactionType.expense,
  categoryId: categories.byName(category).id,
  occurredAt: at,
  title: category,
);

Future<void> setLimit(String category, int minor) =>
    categories.update(categories.byName(category).copyWith(limitMinor: minor));

/// The designs' history: five previous periods and RM 760 so far.
Future<void> designHistory() async {
  await setLimit('Food', 40000);
  await setLimit('Transport', 30000);
  await setLimit('Shopping', 20000);
  // 15 Sep – 14 Oct: RM 2,010 over six categories.
  final sep = DateTime(2026, 9, 20, 12);
  await spend(51200, 'Food', sep);
  await spend(61200, 'Bills', sep);
  await spend(28600, 'Transport', sep);
  await spend(23400, 'Shopping', sep);
  await spend(18600, 'Fun', sep);
  await spend(18000, 'Health', sep);
  for (final (month, minor) in [
    (8, 191000),
    (7, 154000),
    (6, 182000),
    (5, 165000),
  ]) {
    await spend(minor, 'Food', DateTime(2026, month, 20, 12));
  }
  await spend(76000, 'Food', DateTime(2026, 11, 2, 12));
}

List<ListGroupRow> rows(WidgetTester tester) =>
    tester.widgetList<ListGroupRow>(find.byType(ListGroupRow)).toList();

void main() {
  group('S25 Past periods', () {
    testWidgets('shows the current period with days left', (tester) async {
      await pumpApp(tester, location: Routes.pastPeriods);
      expect(find.text('Past periods'), findsOneWidget);
      expect(find.text('CURRENT PERIOD'), findsOneWidget);
      expect(find.text('15 Oct – 14 Nov'), findsOneWidget);
      expect(find.text('10 days left'), findsOneWidget);
      expect(find.text('RM 760 of RM 2,000 spent'), findsOneWidget);
      expect(
        tester.widget<AppProgressBar>(find.byType(AppProgressBar)).value,
        0.38,
      );
    });

    testWidgets('lists previous periods newest first with results', (
      tester,
    ) async {
      await pumpApp(
        tester,
        location: Routes.pastPeriods,
        theme: AppTheme.light,
      );
      expect(find.text('PREVIOUS'), findsOneWidget);
      final shown = rows(tester);
      expect(
        [for (final r in shown) r.title],
        [
          '15 Sep – 14 Oct',
          '15 Aug – 14 Sep',
          '15 Jul – 14 Aug',
          '15 Jun – 14 Jul',
          '15 May – 14 Jun',
        ],
      );
      expect(shown.first.subtitle, 'RM 2,010 of RM 2,000');
      expect(
        [for (final r in shown) r.value],
        [
          'Over by RM 10',
          'RM 90 under',
          'RM 460 under',
          'RM 180 under',
          'RM 350 under',
        ],
      );
      expect(shown.first.valueColor, AppColors.light.negative);
      expect(shown[1].valueColor, AppColors.light.positive);
    });

    testWidgets('a row opens its period', (tester) async {
      await pumpApp(tester, location: Routes.pastPeriods);
      await tester.tap(find.text('15 Sep – 14 Oct'));
      await tester.pumpAndSettle();
      expect(find.byType(PeriodDetailScreen), findsOneWidget);
      expect(find.text('RM 2,010.00'), findsOneWidget);
    });

    testWidgets('without a budget rows show only what was spent', (
      tester,
    ) async {
      await pumpApp(tester, location: Routes.pastPeriods, budget: null);
      expect(find.byType(AppProgressBar), findsNothing);
      expect(find.text('RM 760 spent'), findsOneWidget);
      expect(rows(tester).first.subtitle, 'RM 2,010 spent');
      expect(rows(tester).first.value, isNull);
    });

    testWidgets('no previous periods hides the section', (tester) async {
      await pumpApp(
        tester,
        location: Routes.pastPeriods,
        seed: () => spend(76000, 'Food', DateTime(2026, 11, 2, 12)),
      );
      expect(find.text('PREVIOUS'), findsNothing);
      expect(find.byType(ListGroupRow), findsNothing);
    });

    testWidgets('S20 opens it', (tester) async {
      await pumpApp(tester, location: Routes.pastPeriods);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      container.read(appRouterProvider).go(Routes.insights);
      await tester.pumpAndSettle();
      await tester.tap(find.text('6 months'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('View past periods'));
      await tester.tap(find.text('View past periods'));
      await tester.pumpAndSettle();
      expect(find.byType(PastPeriodsScreen), findsOneWidget);
    });
  });

  group('S26 Period detail', () {
    final sepPeriod = Routes.period(DateTime(2026, 9, 15));

    testWidgets('shows spent, the result and the budget', (tester) async {
      await pumpApp(tester, location: sepPeriod);
      expect(find.text('15 Sep – 14 Oct'), findsOneWidget);
      expect(find.text('SPENT'), findsOneWidget);
      expect(find.text('RM 2,010.00'), findsOneWidget);
      expect(find.text('Over by RM 10'), findsOneWidget);
      expect(find.text('Budget RM 2,000'), findsOneWidget);
      expect(
        tester.widget<AppProgressBar>(find.byType(AppProgressBar)).color,
        AppColors.dark.negative,
      );
    });

    testWidgets('each category against its limit', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, location: sepPeriod);
      expect(find.text('BY CATEGORY'), findsOneWidget);
      for (final label in [
        'Bills, No limit, RM 612',
        'Food, RM 112 over, limit RM 400, RM 512',
        'Transport, RM 14 under, limit RM 300, RM 286',
        'Shopping, RM 34 over, limit RM 200, RM 234',
        'Fun, No limit, RM 186',
        'Health, No limit, RM 180',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }
      handle.dispose();
    });

    testWidgets('an archived category keeps its history', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(
        tester,
        location: sepPeriod,
        seed: () async {
          await designHistory();
          await categories.archive(categories.byName('Fun').id);
        },
      );
      expect(find.bySemanticsLabel('Fun, No limit, RM 186'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('under budget reads as under', (tester) async {
      await pumpApp(tester, location: Routes.period(DateTime(2026, 8, 15)));
      expect(find.text('RM 90 under'), findsOneWidget);
      expect(
        tester.widget<AppProgressBar>(find.byType(AppProgressBar)).color,
        isNull,
      );
    });

    testWidgets('without a budget there is no bar', (tester) async {
      await pumpApp(tester, location: sepPeriod, budget: null);
      expect(find.text('No budget'), findsOneWidget);
      expect(find.byType(AppProgressBar), findsNothing);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpApp(tester, location: Routes.pastPeriods, theme: theme);
      Color? background(Type screen) => tester
          .widget<Scaffold>(
            find.descendant(
              of: find.byType(screen),
              matching: find.byType(Scaffold),
            ),
          )
          .backgroundColor;
      expect(background(PastPeriodsScreen), colors.ground);
      expect(rows(tester).first.valueColor, colors.negative);
      await tester.tap(find.text('15 Sep – 14 Oct'));
      await tester.pumpAndSettle();
      expect(background(PeriodDetailScreen), colors.ground);
    });
  }
}
