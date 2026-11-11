import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/amount_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/budget_hero.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/features/budgets/presentation/budgets_screen.dart';
import 'package:ctrl_spend/features/budgets/presentation/category_budget_row.dart';
import 'package:ctrl_spend/features/budgets/presentation/monthly_budget_card.dart';
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

/// 4 Nov 2026, 9:00, the designs' "today".
final now = DateTime(2026, 11, 4, 9);

late FakePreferencesRepository prefs;
late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpBudgets(
  WidgetTester tester, {
  int? budget = 200000,
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  prefs = FakePreferencesRepository(
    Preferences(
      onboardingComplete: true,
      monthStartDay: const DayOfMonth(15),
      monthlyBudgetMinor: budget,
      theme: theme,
    ),
  );
  transactions = FakeTransactionRepository();
  categories = FakeCategoryRepository();
  await seed?.call();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: prefs,
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
  container.read(appRouterProvider).go(Routes.budgets);
  await tester.pumpAndSettle();
}

Future<void> spend(int minor, String category) => transactions.add(
  amountMinor: minor,
  type: TransactionType.expense,
  categoryId: categories.byName(category).id,
  occurredAt: DateTime(2026, 11, 2, 12),
  title: category,
);

Future<void> setLimit(String category, int minor) =>
    categories.update(categories.byName(category).copyWith(limitMinor: minor));

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

Finder get saveButton => find.widgetWithText(PrimaryButton, 'Save');

bool saveEnabled(WidgetTester tester) =>
    tester.widget<PrimaryButton>(saveButton).onPressed != null;

Future<void> save(WidgetTester tester) async {
  await tester.tap(saveButton);
  // Let the save start before settling, or settle can return first.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

Text textOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text));

void main() {
  group('monthly budget card', () {
    testWidgets('shows what is left and what was spent', (tester) async {
      await pumpBudgets(tester, seed: () => spend(76000, 'Bills'));
      expect(find.text('Budgets'), findsWidgets);
      expect(find.text('15 OCT – 14 NOV'), findsOneWidget);
      expect(find.text('RM 1,240.00', findRichText: true), findsOneWidget);
      expect(find.text('left'), findsOneWidget);
      expect(find.text('RM 760.00 of RM 2,000.00 spent'), findsOneWidget);
    });

    testWidgets('amber at 80–99%, red with "over" past the budget', (
      tester,
    ) async {
      await pumpBudgets(tester, seed: () => spend(184000, 'Bills'));
      expect(textOf(tester, 'left').style!.color, AppColors.light.warning);

      await spend(17000, 'Bills');
      await tester.pumpAndSettle();
      expect(find.text('RM 10.00', findRichText: true), findsOneWidget);
      expect(textOf(tester, 'over').style!.color, AppColors.light.negative);
      final bar = tester.widget<AppProgressBar>(
        find.descendant(
          of: find.byType(MonthlyBudgetCard),
          matching: find.byType(AppProgressBar),
        ),
      );
      expect(bar.color, AppColors.light.negative);
    });

    testWidgets('no budget reads "Not set" with a link', (tester) async {
      await pumpBudgets(tester, budget: null);
      expect(find.text('Not set'), findsOneWidget);
      expect(find.text('Set a monthly budget'), findsOneWidget);
    });
  });

  group('editing the monthly budget', () {
    testWidgets('sets a budget from "Not set"', (tester) async {
      await pumpBudgets(tester, budget: null);
      await tester.tap(find.text('Set a monthly budget'));
      await tester.pumpAndSettle();
      expect(find.text('Monthly budget'), findsWidgets);
      expect(find.text('Remove'), findsNothing);
      await type(tester, '150000');
      await save(tester);
      expect((await prefs.read()).monthlyBudgetMinor, 150000);
      expect(find.text('RM 1,500.00', findRichText: true), findsOneWidget);
    });

    testWidgets("can't go below the category limits", (tester) async {
      await pumpBudgets(
        tester,
        seed: () async {
          await setLimit('Food', 40000);
          await setLimit('Transport', 50000);
        },
      );
      await tester.tap(find.byType(MonthlyBudgetCard));
      await tester.pumpAndSettle();
      // RM 2,000.00 → RM 200.00
      await backspace(tester, 1);
      expect(
        find.text('Your category limits add up to RM 900. Set at least that.'),
        findsOneWidget,
      );
      expect(saveEnabled(tester), isFalse);
      await type(tester, '0');
      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('Remove clears the budget', (tester) async {
      await pumpBudgets(tester);
      await tester.tap(find.byType(MonthlyBudgetCard));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect((await prefs.read()).monthlyBudgetMinor, isNull);
      expect(find.text('Not set'), findsOneWidget);
    });
  });

  group('by category', () {
    testWidgets('lists limited categories with percent, spent and left', (
      tester,
    ) async {
      await pumpBudgets(
        tester,
        seed: () async {
          await setLimit('Food', 40000);
          await setLimit('Shopping', 20000);
          await spend(32800, 'Food');
          await spend(5000, 'Shopping');
        },
      );
      expect(find.byType(CategoryBudgetRow), findsNWidgets(2));
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('Spent RM 328 · Left RM 72'), findsOneWidget);
      expect(textOf(tester, '82%').style!.color, AppColors.light.warning);
      expect(find.text('25%'), findsOneWidget);
      expect(textOf(tester, '25%').style!.color, AppColors.light.ink);
      expect(find.text('Transport'), findsNothing, reason: 'no limit');
    });

    testWidgets('over the limit reads "Over by" in red', (tester) async {
      await pumpBudgets(
        tester,
        seed: () async {
          await setLimit('Food', 40000);
          await spend(51200, 'Food');
        },
      );
      expect(find.text('128%'), findsOneWidget);
      expect(textOf(tester, '128%').style!.color, AppColors.light.negative);
      expect(find.text('Spent RM 512 · Over by RM 112'), findsOneWidget);
    });

    for (final (spent, colour) in [
      (31999, AppColors.light.ink),
      (32000, AppColors.light.warning),
      (40000, AppColors.light.negative),
    ]) {
      testWidgets('the hero thresholds apply at $spent of 40000', (
        tester,
      ) async {
        await pumpBudgets(
          tester,
          seed: () async {
            await setLimit('Food', 40000);
            await spend(spent, 'Food');
          },
        );
        final row = tester.widget<AppProgressBar>(
          find.descendant(
            of: find.byType(CategoryBudgetRow),
            matching: find.byType(AppProgressBar),
          ),
        );
        expect(row.color, colour);
      });
    }

    testWidgets('Add sets a limit on a category that has none', (tester) async {
      await pumpBudgets(tester, seed: () => setLimit('Food', 40000));
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('Add a limit'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Food'),
        ),
        findsNothing,
        reason: 'already has one',
      );
      await tester.tap(find.text('Transport'));
      await tester.pumpAndSettle();
      expect(find.text('Transport budget'), findsOneWidget);
      expect(find.text('RM 1,600 left to allocate'), findsOneWidget);
      await type(tester, '30000');
      await save(tester);
      expect(categories.byName('Transport').limitMinor, 30000);
      expect(find.byType(CategoryBudgetRow), findsNWidgets(2));
    });

    testWidgets('editing respects the cap; Remove keeps the category', (
      tester,
    ) async {
      await pumpBudgets(
        tester,
        seed: () async {
          await setLimit('Food', 40000);
          await setLimit('Transport', 150000);
          await spend(1000, 'Food');
        },
      );
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.text('RM 500 left to allocate'), findsOneWidget);
      await type(tester, '0');
      expect(saveEnabled(tester), isFalse, reason: 'RM 4,000 > RM 500');

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(categories.byName('Food').limitMinor, isNull);
      expect(categories.byName('Food').archived, isFalse);
      expect(transactions.all, hasLength(1));
      expect(find.byType(CategoryBudgetRow), findsOneWidget);
    });

    testWidgets('Add is hidden once every category has a limit', (
      tester,
    ) async {
      await pumpBudgets(
        tester,
        budget: null,
        seed: () async {
          for (final c in [
            'Food',
            'Transport',
            'Shopping',
            'Bills',
            'Fun',
            'Health',
          ]) {
            await setLimit(c, 10000);
          }
        },
      );
      expect(find.text('Add'), findsNothing);
    });
  });

  testWidgets('Home follows a budget change', (tester) async {
    await pumpBudgets(tester);
    await tester.tap(find.byType(MonthlyBudgetCard));
    await tester.pumpAndSettle();
    await type(tester, '0');
    await save(tester);
    container.read(appRouterProvider).go(Routes.home);
    await tester.pumpAndSettle();
    expect(
      tester.widget<BudgetHero>(find.byType(BudgetHero)).budgetMinor,
      2000000,
    );
  });

  testWidgets('the sheet keeps its dark-mode card colour', (tester) async {
    await pumpBudgets(tester, theme: AppTheme.dark);
    await tester.tap(find.byType(MonthlyBudgetCard));
    await tester.pumpAndSettle();
    expect(find.byType(AmountSheetResult), findsNothing);
    final card = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('PER MONTH'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((card.decoration! as BoxDecoration).color, AppColors.dark.fillSoft);
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpBudgets(
        tester,
        theme: theme,
        seed: () async {
          await setLimit('Food', 40000);
          await spend(32800, 'Food');
        },
      );
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(BudgetsScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      final card = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(MonthlyBudgetCard),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.color, colors.surface);
      expect(textOf(tester, '82%').style!.color, colors.warning);
    });
  }
}
