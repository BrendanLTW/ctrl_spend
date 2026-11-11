import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/category_picker_tile.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/add_transaction_screen.dart';
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

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpAt(
  WidgetTester tester,
  String route, {
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed,
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
            monthlyBudgetMinor: 200000,
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
  unawaited(container.read(appRouterProvider).push(route));
  await tester.pumpAndSettle();
}

/// Presses keys on the open keypad sheet.
Future<void> type(WidgetTester tester, String keys) async {
  for (final key in keys.split('')) {
    await tester.tap(find.widgetWithText(InkWell, key).last);
    await tester.pump();
  }
}

Future<void> done(WidgetTester tester) async {
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}

/// Tiles show their label in capitals, so match the widget's label.
Finder tileFinder(String label) =>
    find.byWidgetPredicate((w) => w is CategoryPickerTile && w.label == label);

Future<void> tapTile(WidgetTester tester, String label) async {
  await tester.ensureVisible(tileFinder(label));
  await tester.tap(tileFinder(label));
  await tester.pumpAndSettle();
}

bool saveEnabled(WidgetTester tester) =>
    tester
        .widget<PrimaryButton>(find.widgetWithText(PrimaryButton, 'Save'))
        .onPressed !=
    null;

List<String> tileLabels(WidgetTester tester) => [
  for (final t in tester.widgetList<CategoryPickerTile>(
    find.byType(CategoryPickerTile),
  ))
    t.label,
];

CategoryPickerTile tile(WidgetTester tester, String label) =>
    tester.widget<CategoryPickerTile>(tileFinder(label));

Future<Transaction> seedLunch({String title = 'Nasi lemak'}) =>
    transactions.add(
      amountMinor: 1250,
      type: TransactionType.expense,
      categoryId: categories.byName('Food').id,
      occurredAt: DateTime(2026, 11, 4, 8, 15),
      title: title,
    );

Future<void> save(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(PrimaryButton, 'Save'));
  // Let the save start before settling, or settle can return first.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

void main() {
  group('S12 New expense', () {
    testWidgets('opens with the keypad and Save disabled', (tester) async {
      await pumpAt(tester, Routes.add);
      expect(find.text('New expense'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget, reason: 'keypad sheet');
      await done(tester);
      expect(find.text('Delete'), findsNothing);
      expect(saveEnabled(tester), isFalse);
      expect(find.text('Today, 4 Nov'), findsOneWidget);
      expect(tileLabels(tester), [
        'Food',
        'Transport',
        'Shopping',
        'Bills',
        'Fun',
        'Health',
      ]);
    });

    testWidgets('Save needs an amount and a category', (tester) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '1250');
      await done(tester);
      expect(find.text('12.50'), findsOneWidget);
      expect(saveEnabled(tester), isFalse, reason: 'no category');
      await tapTile(tester, 'Food');
      expect(saveEnabled(tester), isTrue);
      expect(tile(tester, 'Food').selected, isTrue);

      await tester.tap(find.text('12.50'));
      await tester.pumpAndSettle();
      await type(tester, '0000');
      // Backspace back to 0.
      for (var i = 0; i < 8; i++) {
        await tester.tap(find.bySemanticsLabel('Backspace').last);
        await tester.pump();
      }
      await done(tester);
      expect(saveEnabled(tester), isFalse, reason: 'amount 0');
    });

    testWidgets('saves with the note as title, then closes', (tester) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '1250');
      await done(tester);
      await tapTile(tester, 'Food');
      await tester.enterText(find.byType(TextField), '  Nasi lemak ');
      await save(tester);
      final saved = transactions.all.single;
      expect(saved.amountMinor, 1250);
      expect(saved.type, TransactionType.expense);
      expect(saved.categoryId, categories.byName('Food').id);
      expect(saved.title, 'Nasi lemak');
      expect(saved.occurredAt, now.toUtc());
      expect(find.byType(AddTransactionScreen), findsNothing);
    });

    testWidgets('a blank note uses the category name', (tester) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '500');
      await done(tester);
      await tapTile(tester, 'Transport');
      await save(tester);
      expect(transactions.all.single.title, 'Transport');
    });

    testWidgets('the note stops at 60 characters', (tester) async {
      await pumpAt(tester, Routes.add);
      await done(tester);
      await tester.enterText(find.byType(TextField), 'x' * 80);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.controller!.text.length,
        AddTransactionScreen.maxTitleLength,
      );
    });
  });

  group('Expense | Income', () {
    testWidgets('switching swaps the categories and clears the choice', (
      tester,
    ) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '1000');
      await done(tester);
      await tapTile(tester, 'Food');
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('New income'), findsOneWidget);
      expect(tileLabels(tester), ['Salary', 'Gifts']);
      expect(saveEnabled(tester), isFalse, reason: 'Food cleared');
      final digits = tester.widget<Text>(find.text('10.00'));
      expect(digits.style!.color, AppColors.light.positive);
    });

    testWidgets('?type=income opens New income', (tester) async {
      await pumpAt(tester, '${Routes.add}?type=income');
      await done(tester);
      expect(find.text('New income'), findsOneWidget);
      expect(tileLabels(tester), ['Salary', 'Gifts']);
    });

    testWidgets('saves income', (tester) async {
      await pumpAt(tester, '${Routes.add}?type=income');
      await type(tester, '480000');
      await done(tester);
      await tapTile(tester, 'Salary');
      await save(tester);
      final saved = transactions.all.single;
      expect(saved.type, TransactionType.income);
      expect(saved.title, 'Salary');
    });
  });

  testWidgets('More lists every category; its pick joins the tiles', (
    tester,
  ) async {
    await pumpAt(
      tester,
      Routes.add,
      seed: () async {
        for (final name in ['Coffee', 'Books', 'Travel']) {
          await categories.add(
            name: name,
            type: TransactionType.expense,
            iconKey: CategoryIconKey.coffee,
            colorKey: CategoryColorKey.purple,
          );
        }
      },
    );
    await done(tester);
    expect(tileLabels(tester), hasLength(8));
    expect(tileLabels(tester), isNot(contains('Travel')));

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Category'), findsOneWidget);
    // The ninth row is below the fold of the sheet's list.
    await tester.ensureVisible(find.text('Travel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();

    expect(tileLabels(tester), hasLength(8));
    expect(tile(tester, 'Travel').selected, isTrue);
  });

  group('date', () {
    testWidgets('the picker sets the date and keeps the time', (tester) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '1000');
      await done(tester);
      await tapTile(tester, 'Food');
      await tester.tap(find.text('Today, 4 Nov'));
      await tester.pumpAndSettle();
      expect(find.text('Date'), findsOneWidget);

      await tester.tap(find.text('5'));
      await tester.pump();
      expect(find.text('Set 4 Nov'), findsOneWidget, reason: 'future day');
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('Set 2 Nov'));
      await tester.pumpAndSettle();
      expect(find.text('Mon, 2 Nov'), findsOneWidget);

      await save(tester);
      expect(
        transactions.all.single.occurredAt,
        DateTime(2026, 11, 2, 9).toUtc(),
      );
    });

    testWidgets('yesterday reads "Yesterday"', (tester) async {
      await pumpAt(tester, Routes.add);
      await done(tester);
      await tester.tap(find.text('Today, 4 Nov'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('Set 3 Nov'));
      await tester.pumpAndSettle();
      expect(find.text('Yesterday, 3 Nov'), findsOneWidget);
    });
  });

  group('S13 Edit transaction', () {
    testWidgets('opens filled in, with Delete and no keypad', (tester) async {
      late Transaction lunch;
      await pumpAt(
        tester,
        Routes.editTransaction(1),
        seed: () async => lunch = await seedLunch(),
      );
      expect(lunch.id, 1);
      expect(find.text('Edit transaction'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
      expect(find.text('12.50'), findsOneWidget);
      expect(tile(tester, 'Food').selected, isTrue);
      expect(find.text('Nasi lemak'), findsOneWidget);
      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('saving updates the same transaction', (tester) async {
      await pumpAt(tester, Routes.editTransaction(1), seed: seedLunch);
      await tester.tap(find.text('12.50'));
      await tester.pumpAndSettle();
      await type(tester, '0');
      await done(tester);
      await tapTile(tester, 'Transport');
      await tester.enterText(find.byType(TextField), 'Taxi');
      await save(tester);

      final saved = transactions.all.single;
      expect(saved.id, 1);
      expect(saved.amountMinor, 12500);
      expect(saved.categoryId, categories.byName('Transport').id);
      expect(saved.title, 'Taxi');
      expect(saved.occurredAt, DateTime(2026, 11, 4, 8, 15).toUtc());
    });

    testWidgets('a title that was the category name shows a blank note', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.editTransaction(1),
        seed: () => seedLunch(title: 'Food'),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('an archived category stays selected', (tester) async {
      await pumpAt(
        tester,
        Routes.editTransaction(1),
        seed: () async {
          await seedLunch();
          await categories.archive(categories.byName('Food').id);
        },
      );
      expect(tile(tester, 'Food').selected, isTrue);
    });

    testWidgets('Delete asks first; Cancel keeps it', (tester) async {
      await pumpAt(tester, Routes.editTransaction(1), seed: seedLunch);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this transaction?'), findsOneWidget);
      expect(
        find.text(
          'Nasi lemak (RM 12.50) will be removed and RM 12.50 goes back to '
          'your Food budget.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(transactions.all, hasLength(1));
      expect(find.byType(AddTransactionScreen), findsOneWidget);
    });

    testWidgets('confirming deletes and closes', (tester) async {
      await pumpAt(tester, Routes.editTransaction(1), seed: seedLunch);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AppDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(transactions.all, isEmpty);
      expect(find.byType(AddTransactionScreen), findsNothing);
    });

    testWidgets('income uses the shorter delete copy', (tester) async {
      await pumpAt(
        tester,
        Routes.editTransaction(1),
        seed: () => transactions.add(
          amountMinor: 480000,
          type: TransactionType.income,
          categoryId: categories.byName('Salary').id,
          occurredAt: now,
          title: 'Salary',
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        find.text('Salary (RM 4,800.00) will be removed.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('a saved expense shows on Home straight away', (tester) async {
    await pumpAt(tester, Routes.add);
    await type(tester, '1820');
    await done(tester);
    await tapTile(tester, 'Transport');
    await tester.enterText(find.byType(TextField), 'Grab to KLCC');
    await save(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Grab to KLCC'), findsOneWidget);
    expect(find.text('${MoneyFormatter.minus}RM 18.20'), findsOneWidget);
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpAt(
        tester,
        Routes.editTransaction(1),
        theme: theme,
        seed: seedLunch,
      );
      final card = tester.widget<Material>(
        find
            .ancestor(
              of: find.text('TOTAL AMOUNT'),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.color, colors.surface);
      final selected = tester.widget<AnimatedContainer>(
        find.descendant(
          of: tileFinder('Food'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect((selected.decoration! as BoxDecoration).color, colors.ink);
      expect(tester.widget<Text>(find.text('12.50')).style!.color, colors.ink);
    });
  }
}
