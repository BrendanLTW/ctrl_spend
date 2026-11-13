import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/category_picker_tile.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/swipe_to_delete.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/presentation/category_manager_screen.dart';
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

late FakeCategoryRepository categories;
late FakeTransactionRepository transactions;
late ProviderContainer container;

Future<void> pumpManager(
  WidgetTester tester, {
  int? budget = 200000,
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  categories = FakeCategoryRepository();
  transactions = FakeTransactionRepository();
  categories.isUsed = (id) => transactions.all.any((t) => t.categoryId == id);
  await seed?.call();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: FakePreferencesRepository(
          Preferences(
            onboardingComplete: true,
            monthlyBudgetMinor: budget,
            theme: theme,
          ),
        ),
        categories: categories,
        transactions: transactions,
      ),
      clockProvider.overrideWithValue(() => DateTime(2026, 11, 4, 9)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  // push() completes only when the screen closes, so don't wait for it.
  unawaited(container.read(appRouterProvider).push(Routes.categories));
  await tester.pumpAndSettle();
}

List<String> rowTitles(WidgetTester tester) => [
  for (final r in tester.widgetList<ListGroupRow>(find.byType(ListGroupRow)))
    r.title,
];

Future<void> openAdd(WidgetTester tester) async {
  await tester.tap(find.text('Add'));
  await tester.pumpAndSettle();
}

Finder get createButton =>
    find.widgetWithText(PrimaryButton, 'Create category');

Future<void> create(WidgetTester tester) async {
  await tester.ensureVisible(createButton);
  await tester.tap(createButton);
  // Let the save start before settling, or settle can return first.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

Future<void> swipeDelete(WidgetTester tester, String name) async {
  await tester.drag(
    find.widgetWithText(ListGroupRow, name),
    const Offset(-150, 0),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(SwipeToDelete),
      matching: find.text('Delete'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('S22 Category manager', () {
    testWidgets('lists expense then income, with the note', (tester) async {
      await pumpManager(tester);
      expect(find.text('EXPENSE'), findsOneWidget);
      expect(find.text('INCOME'), findsOneWidget);
      expect(find.text('ARCHIVED'), findsNothing);
      expect(rowTitles(tester), [
        'Food',
        'Transport',
        'Shopping',
        'Bills',
        'Fun',
        'Health',
        'Salary',
        'Gifts',
      ]);
      expect(
        find.text(
          'Categories with transactions are archived instead of deleted, so '
          'your history stays intact.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('archived categories have Restore', (tester) async {
      await pumpManager(
        tester,
        seed: () => categories.archive(categories.byName('Gifts').id),
      );
      expect(find.text('ARCHIVED'), findsOneWidget);
      expect(rowTitles(tester), isNot(contains('Gifts')));
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();
      expect(categories.byName('Gifts').archived, isFalse);
      expect(find.text('ARCHIVED'), findsNothing);
      expect(rowTitles(tester), contains('Gifts'));
    });

    testWidgets('an unused category is deleted', (tester) async {
      await pumpManager(tester);
      await swipeDelete(tester, 'Health');
      expect(find.text('Category deleted'), findsOneWidget);
      expect(rowTitles(tester), isNot(contains('Health')));
      expect(find.text('ARCHIVED'), findsNothing);
      hideAppToast();
    });

    testWidgets('a used category is archived, its history kept', (
      tester,
    ) async {
      await pumpManager(
        tester,
        seed: () => transactions.add(
          amountMinor: 1250,
          type: TransactionType.expense,
          categoryId: categories.byName('Food').id,
          occurredAt: DateTime(2026, 11, 4, 8),
          title: 'Nasi lemak',
        ),
      );
      await swipeDelete(tester, 'Food');
      expect(find.text('Food archived — it has transactions'), findsOneWidget);
      expect(categories.byName('Food').archived, isTrue);
      expect(transactions.all, hasLength(1));
      expect(find.text('ARCHIVED'), findsOneWidget);
      hideAppToast();
    });

    testWidgets('Settings opens it', (tester) async {
      await pumpManager(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      unawaited(container.read(appRouterProvider).push(Routes.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryManagerScreen), findsOneWidget);
    });
  });

  group('S24 New category', () {
    testWidgets('Create needs a name; it adds the category last', (
      tester,
    ) async {
      await pumpManager(tester);
      await openAdd(tester);
      expect(find.text('New category'), findsOneWidget);
      expect(tester.widget<PrimaryButton>(createButton).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '  Coffee ');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Coffee').first);
      await tester.tap(find.bySemanticsLabel('Purple'));
      await tester.pump();
      await create(tester);

      final coffee = categories.byName('Coffee');
      expect(coffee.type, TransactionType.expense);
      expect(coffee.iconKey, CategoryIconKey.coffee);
      expect(coffee.colorKey, CategoryColorKey.purple);
      expect(coffee.limitMinor, isNull);
      expect(find.text('New category'), findsNothing);
      expect(rowTitles(tester).indexOf('Coffee'), 6, reason: 'after Health');
    });

    testWidgets('the preview tile follows the icon and colour', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpManager(tester);
      await openAdd(tester);
      CategoryTile preview() => tester.widget<CategoryTile>(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(CategoryTile),
        ),
      );
      expect(preview().icon, categoryIcon(CategoryIconKey.food));
      expect(preview().color, CategoryColorKey.orange);
      await tester.tap(find.bySemanticsLabel('Book'));
      await tester.tap(find.bySemanticsLabel('Green'));
      await tester.pump();
      expect(preview().icon, categoryIcon(CategoryIconKey.book));
      expect(preview().color, CategoryColorKey.green);
      handle.dispose();
    });

    testWidgets('a monthly limit, capped by the budget', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpManager(
        tester,
        seed: () => categories.update(
          categories.byName('Food').copyWith(limitMinor: 150000),
        ),
      );
      await openAdd(tester);
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.pump();
      await tester.ensureVisible(find.text('Monthly limit'));
      expect(find.text('Optional'), findsOneWidget);
      await tester.tap(find.text('Monthly limit'));
      await tester.pumpAndSettle();
      expect(find.text('RM 500 left to allocate'), findsOneWidget);
      for (final key in '20000'.split('')) {
        await tester.tap(find.widgetWithText(InkWell, key).last);
        await tester.pump();
      }
      await tester.tap(find.widgetWithText(PrimaryButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('RM 200'), findsOneWidget);
      await create(tester);
      expect(categories.byName('Coffee').limitMinor, 20000);
      handle.dispose();
    });

    testWidgets('income has no limit row and is saved as income', (
      tester,
    ) async {
      await pumpManager(tester);
      await openAdd(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Income'),
        ),
      );
      await tester.pump();
      expect(find.text('Monthly limit'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Bonus');
      await tester.pump();
      await create(tester);
      expect(categories.byName('Bonus').type, TransactionType.income);
    });

    testWidgets('a duplicate name shows an error and stays open', (
      tester,
    ) async {
      await pumpManager(tester);
      await openAdd(tester);
      await tester.enterText(find.byType(TextField), 'food');
      await tester.pump();
      await create(tester);
      expect(
        find.text('You already have an expense category called food.'),
        findsOneWidget,
      );
      expect(find.text('New category'), findsOneWidget);
      // Typing again clears the error.
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.pump();
      expect(find.textContaining('You already have'), findsNothing);
    });

    testWidgets('a new category shows in S12; an archived one does not', (
      tester,
    ) async {
      await pumpManager(tester);
      await openAdd(tester);
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.pump();
      await create(tester);
      await categories.archive(categories.byName('Fun').id);
      unawaited(container.read(appRouterProvider).push(Routes.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      final labels = [
        for (final t in tester.widgetList<CategoryPickerTile>(
          find.byType(CategoryPickerTile),
        ))
          t.label,
      ];
      expect(labels, contains('Coffee'));
      expect(labels, isNot(contains('Fun')));
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpManager(tester, theme: theme);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(CategoryManagerScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      await openAdd(tester);
      final field = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(TextField),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((field.decoration! as BoxDecoration).color, colors.fillSoft);
    });
  }
}
