import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/presentation/category_detail_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fake_transaction_repository.dart';

/// 4 Nov 2026; with start day 15 the period is 15 Oct – 14 Nov, 10 days
/// to go.
final now = DateTime(2026, 11, 4, 9);

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpDetail(
  WidgetTester tester, {
  String category = 'Food',
  int? budget = 200000,
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed = designFood,
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
  unawaited(
    container
        .read(appRouterProvider)
        .push(Routes.category(categories.byName(category).id)),
  );
  await tester.pumpAndSettle();
}

Future<void> spend(int minor, String category, DateTime at, String title) =>
    transactions.add(
      amountMinor: minor,
      type: category == 'Salary'
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: categories.byName(category).id,
      occurredAt: at,
      title: title,
    );

/// Food: RM 400 limit, RM 328 this period (82%), 7 transactions in all.
Future<void> designFood() async {
  await categories.update(
    categories.byName('Food').copyWith(limitMinor: 40000),
  );
  await spend(5000, 'Food', DateTime(2026, 10, 10, 12), 'Last period');
  await spend(8640, 'Food', DateTime(2026, 11, 1, 12), 'Jaya Grocer');
  await spend(1250, 'Food', DateTime(2026, 11, 4, 8), 'Nasi lemak');
  for (final day in [20, 22, 25, 28]) {
    await spend(5727, 'Food', DateTime(2026, 10, day, 12), 'Lunch');
  }
}

Future<void> tapRow(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  // Let a save start before settling, or settle can return first.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(PrimaryButton, 'Save'));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

void main() {
  group('S23 Category detail', () {
    testWidgets('shows this period against the limit', (tester) async {
      await pumpDetail(tester, theme: AppTheme.light);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Expense · 7 transactions'), findsOneWidget);
      // 1,250 + 8,640 + 4 × 5,727 = 32,798: 81%, in the warning range.
      expect(find.text('81%'), findsOneWidget);
      expect(find.text('RM 327.98'), findsOneWidget);
      expect(find.text('of RM 400'), findsOneWidget);
      expect(find.text('RM 72.02 left'), findsOneWidget);
      expect(find.text('10 days to go'), findsOneWidget);
      expect(
        tester.widget<AppProgressBar>(find.byType(AppProgressBar)).color,
        AppColors.light.warning,
      );
    });

    testWidgets('over the limit reads as over, in red', (tester) async {
      await pumpDetail(
        tester,
        theme: AppTheme.light,
        seed: () async {
          await designFood();
          await spend(10000, 'Food', DateTime(2026, 11, 3, 12), 'Dinner');
        },
      );
      expect(find.text('Over by RM 27.98'), findsOneWidget);
      expect(
        tester.widget<AppProgressBar>(find.byType(AppProgressBar)).color,
        AppColors.light.negative,
      );
    });

    testWidgets('without a limit there is no % or bar', (tester) async {
      await pumpDetail(
        tester,
        category: 'Fun',
        seed: () => spend(4000, 'Fun', DateTime(2026, 11, 2, 12), 'Cinema'),
      );
      expect(find.textContaining('%'), findsNothing);
      expect(find.byType(AppProgressBar), findsNothing);
      expect(find.text('No limit · 10 days to go'), findsOneWidget);
      expect(find.text('Monthly limit'), findsOneWidget);
    });

    testWidgets('an income category has no limit row', (tester) async {
      await pumpDetail(
        tester,
        category: 'Salary',
        seed: () => spend(480000, 'Salary', DateTime(2026, 11, 1, 9), 'Pay'),
      );
      expect(find.text('Income · 1 transaction'), findsOneWidget);
      expect(find.text('RM 4,800'), findsOneWidget);
      expect(find.text('Monthly limit'), findsNothing);
      expect(find.byType(AppProgressBar), findsNothing);
    });

    testWidgets('recent shows the newest five and opens one', (tester) async {
      await pumpDetail(tester);
      final rows = tester
          .widgetList<TransactionRow>(find.byType(TransactionRow))
          .toList();
      expect(rows, hasLength(5));
      expect(rows.first.title, 'Nasi lemak');
      expect(rows.first.caption, 'Today');
      expect(rows[1].caption, 'Sun, 1 Nov');
      expect(rows.first.tile, isNull);
      await tester.ensureVisible(find.text('Nasi lemak'));
      await tapRow(tester, 'Nasi lemak');
      expect(find.byType(TransactionDetailScreen), findsOneWidget);
    });

    testWidgets('Name renames the category', (tester) async {
      await pumpDetail(tester);
      await tapRow(tester, 'Name');
      await tester.enterText(find.byType(TextField), '  Meals ');
      await tester.pump();
      await save(tester);
      expect(categories.byName('Meals').limitMinor, 40000);
      expect(find.text('Meals'), findsWidgets);
    });

    testWidgets('a duplicate name keeps the sheet open', (tester) async {
      await pumpDetail(tester);
      await tapRow(tester, 'Name');
      await tester.enterText(find.byType(TextField), 'fun');
      await tester.pump();
      await save(tester);
      expect(
        find.text('You already have an expense category called fun.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(PrimaryButton, 'Save'), findsOneWidget);
    });

    testWidgets('Icon & colour saves both', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDetail(tester);
      await tapRow(tester, 'Icon & colour');
      await tester.tap(find.bySemanticsLabel('Coffee'));
      await tester.tap(find.bySemanticsLabel('Purple'));
      await tester.pump();
      await save(tester);
      final food = categories.byName('Food');
      expect(food.iconKey, CategoryIconKey.coffee);
      expect(food.colorKey, CategoryColorKey.purple);
      handle.dispose();
    });

    testWidgets('Monthly limit is capped by the budget and removable', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        seed: () async {
          await designFood();
          await categories.update(
            categories.byName('Bills').copyWith(limitMinor: 150000),
          );
        },
      );
      await tapRow(tester, 'Monthly limit');
      // RM 2,000 budget − RM 1,500 for Bills.
      expect(find.text('RM 500 left to allocate'), findsOneWidget);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(categories.byName('Food').limitMinor, isNull);
      expect(find.byType(AppProgressBar), findsNothing);
    });

    testWidgets('Archive switches to Restore', (tester) async {
      await pumpDetail(tester);
      await tester.scrollUntilVisible(find.text('Archive category'), 200);
      await tapRow(tester, 'Archive category');
      expect(categories.byName('Food').archived, isTrue);
      expect(transactions.all, hasLength(7));
      await tapRow(tester, 'Restore category');
      expect(categories.byName('Food').archived, isFalse);
    });

    testWidgets('S22 rows open it', (tester) async {
      await pumpDetail(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      unawaited(container.read(appRouterProvider).push(Routes.categories));
      await tester.pumpAndSettle();
      await tapRow(tester, 'Transport');
      expect(find.byType(CategoryDetailScreen), findsOneWidget);
      expect(find.text('Expense · 0 transactions'), findsOneWidget);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpDetail(tester, theme: theme);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(CategoryDetailScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      expect(
        tester.widget<AppProgressBar>(find.byType(AppProgressBar)).color,
        colors.warning,
      );
    });
  }
}
