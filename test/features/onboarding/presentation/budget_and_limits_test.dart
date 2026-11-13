import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/amount_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/step_indicator.dart';
import 'package:ctrl_spend/features/onboarding/presentation/budget_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/category_limits_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/reminders_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';

const String minus = MoneyFormatter.minus;

late FakePreferencesRepository prefs;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpAt(
  WidgetTester tester,
  String route, {
  Preferences initial = const Preferences(monthlyBudgetMinor: 200000),
  Map<String, int> limits = const {},
}) async {
  // A phone screen, so the keypad and lower rows are on screen.
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  prefs = FakePreferencesRepository(initial);
  categories = FakeCategoryRepository();
  for (final MapEntry(:key, :value) in limits.entries) {
    await categories.update(categories.byName(key).copyWith(limitMinor: value));
  }
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(preferences: prefs, categories: categories),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  container.read(appRouterProvider).go(route);
  await tester.pumpAndSettle();
}

Future<void> type(WidgetTester tester, String keys) async {
  for (final key in keys.split('')) {
    await tester.tap(find.widgetWithText(InkWell, key).last);
    await tester.pump();
  }
}

Future<void> backspace(WidgetTester tester, int times) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(find.bySemanticsLabel('Backspace').last);
    await tester.pump();
  }
}

bool enabled(WidgetTester tester, Finder button) =>
    tester.widget<PrimaryButton>(button).onPressed != null;

Finder get continueButton => find.widgetWithText(PrimaryButton, 'Continue');
Finder get saveButton => find.widgetWithText(PrimaryButton, 'Save');

void main() {
  group('S05 Set your monthly budget', () {
    testWidgets('is step 3 of 5 with the copy and saved budget', (
      tester,
    ) async {
      await pumpAt(tester, Routes.onboardingBudget);
      final step = tester.widget<StepIndicator>(find.byType(StepIndicator));
      expect((step.current, step.total), (3, 5));
      expect(find.text('Set your monthly budget'), findsOneWidget);
      expect(find.text('MONTHLY BUDGET'), findsOneWidget);
      expect(find.text('per month'), findsOneWidget);
      expect(find.text('RM 2,000.00', findRichText: true), findsOneWidget);
    });

    testWidgets('typing sets the amount; Continue saves it', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpAt(
        tester,
        Routes.onboardingBudget,
        initial: const Preferences(),
      );
      expect(enabled(tester, continueButton), isFalse);
      await type(tester, '150000');
      expect(find.text('RM 1,500.00', findRichText: true), findsOneWidget);
      expect(
        find.bySemanticsLabel('Budget RM 1,500.00 per month'),
        findsOneWidget,
      );
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect((await prefs.read()).monthlyBudgetMinor, 150000);
      expect(find.byType(CategoryLimitsScreen), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Skip clears the budget and skips S06', (tester) async {
      await pumpAt(tester, Routes.onboardingBudget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect((await prefs.read()).monthlyBudgetMinor, isNull);
      expect(find.byType(RemindersScreen), findsOneWidget);
      expect(find.byType(CategoryLimitsScreen), findsNothing);
    });

    testWidgets('a budget below the category limits is blocked', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.onboardingBudget,
        limits: {'Food': 40000, 'Transport': 50000},
      );
      expect(enabled(tester, continueButton), isTrue);
      // RM 2,000.00 → RM 200.00
      await backspace(tester, 1);
      expect(
        find.text('Your category limits add up to RM 900. Set at least that.'),
        findsOneWidget,
      );
      expect(enabled(tester, continueButton), isFalse);
    });
  });

  group('S06 Split by category', () {
    testWidgets('is step 4 of 5 with the summary and categories', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.onboardingCategories,
        limits: {'Food': 40000, 'Transport': 30000, 'Shopping': 20000},
      );
      final step = tester.widget<StepIndicator>(find.byType(StepIndicator));
      expect((step.current, step.total), (4, 5));
      expect(find.text('ALLOCATED'), findsOneWidget);
      expect(
        find.text('RM 900 of RM 2,000', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.text('RM 1,100 stays flexible for everything else.'),
        findsOneWidget,
      );
      expect(
        tester.widget<AppProgressBar>(find.byType(AppProgressBar)).value,
        0.45,
      );
      for (final name in [
        'Food',
        'Transport',
        'Shopping',
        'Bills',
        'Fun',
        'Health',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      expect(find.text('Salary'), findsNothing, reason: 'income');
      expect(find.text('RM 400'), findsOneWidget);
      expect(find.text('Add limit'), findsNWidgets(3));
    });

    testWidgets('adding a limit saves it and updates the summary', (
      tester,
    ) async {
      await pumpAt(tester, Routes.onboardingCategories);
      await tester.ensureVisible(find.text('Bills'));
      await tester.tap(find.text('Bills'));
      await tester.pumpAndSettle();
      expect(find.text('Bills budget'), findsOneWidget);
      expect(find.byTooltip('Close'), findsOneWidget, reason: 'no limit yet');
      expect(find.text('RM 2,000 left to allocate'), findsOneWidget);
      expect(enabled(tester, saveButton), isFalse, reason: 'at 0');

      await type(tester, '15000');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(categories.byName('Bills').limitMinor, 15000);
      expect(find.text('RM 150'), findsOneWidget);
      expect(
        find.text('RM 150 of RM 2,000', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('Remove clears a limit', (tester) async {
      await pumpAt(
        tester,
        Routes.onboardingCategories,
        limits: {'Food': 40000},
      );
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.text('Remove'), findsOneWidget);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(categories.byName('Food').limitMinor, isNull);
      expect(find.text('Add limit'), findsNWidgets(6));
    });

    testWidgets('a limit over what is left cannot be saved', (tester) async {
      await pumpAt(
        tester,
        Routes.onboardingCategories,
        limits: {'Food': 150000},
      );
      await tester.tap(find.text('Transport'));
      await tester.pumpAndSettle();
      final room = find.text('RM 500 left to allocate');
      expect(room, findsOneWidget);
      await type(tester, '60000');
      expect(enabled(tester, saveButton), isFalse);
      expect(tester.widget<Text>(room).style!.color, AppColors.light.negative);
      await backspace(tester, 1);
      expect(enabled(tester, saveButton), isTrue);
    });

    testWidgets("editing a limit doesn't count it against itself", (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.onboardingCategories,
        limits: {'Food': 150000},
      );
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.text('RM 2,000 left to allocate'), findsOneWidget);
    });

    testWidgets('dismissing the sheet changes nothing', (tester) async {
      await pumpAt(
        tester,
        Routes.onboardingCategories,
        limits: {'Food': 40000},
      );
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      await type(tester, '9');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(AmountSheetResult), findsNothing);
      expect(categories.byName('Food').limitMinor, 40000);
    });

    testWidgets('without a budget there is no summary and no cap', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.onboardingCategories,
        initial: const Preferences(),
      );
      expect(find.text('ALLOCATED'), findsNothing);
      await tester.tap(find.text('Fun'));
      await tester.pumpAndSettle();
      expect(find.textContaining('left to allocate'), findsNothing);
    });

    for (final action in ['Continue', 'Skip']) {
      testWidgets('$action moves on', (tester) async {
        await pumpAt(tester, Routes.onboardingCategories);
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(find.byType(RemindersScreen), findsOneWidget);
      });
    }

    testWidgets('rows read their limit', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpAt(
        tester,
        Routes.onboardingCategories,
        limits: {'Food': 40000},
      );
      expect(find.bySemanticsLabel('Food, limit RM 400'), findsOneWidget);
      expect(find.bySemanticsLabel('Bills, add limit'), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets('Back from S06 keeps the budget on S05', (tester) async {
    await pumpAt(tester, Routes.onboardingMonth);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetScreen), findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.byType(CategoryLimitsScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('RM 2,000.00', findRichText: true), findsOneWidget);
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('both screens use the theme in ${theme.name} mode', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.onboardingBudget,
        initial: Preferences(theme: theme, monthlyBudgetMinor: 200000),
      );
      final card = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('MONTHLY BUDGET'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((card.decoration! as BoxDecoration).color, colors.surface);

      container.read(appRouterProvider).go(Routes.onboardingCategories);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Add limit').first).style!.color,
        colors.muted,
      );
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      final sheetCard = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('PER MONTH'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((sheetCard.decoration! as BoxDecoration).color, colors.fillSoft);
    });
  }
}
