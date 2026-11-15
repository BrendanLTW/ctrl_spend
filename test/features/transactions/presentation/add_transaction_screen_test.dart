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
import 'package:ctrl_spend/features/transactions/presentation/entry_fields.dart';
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
  // A blank title becomes the category name, as the real one does.
  transactions.categoryName = (id) => categories.byId(id)?.name;
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

/// Presses keys on the keypad: S12's pinned one, or an open keypad sheet.
Future<void> type(WidgetTester tester, String keys) async {
  for (final key in keys.split('')) {
    await tester.tap(find.widgetWithText(InkWell, key).last);
    await tester.pump();
  }
}

/// Closes a keypad sheet (S28, S31).
Future<void> done(WidgetTester tester) async {
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}

/// Tiles show their label in capitals, so match the widget's label.
Finder tileFinder(String label) =>
    find.byWidgetPredicate((w) => w is CategoryPickerTile && w.label == label);

Future<void> tapTile(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    tileFinder(label),
    60,
    scrollable: find.descendant(
      of: find.byType(CategoryTileRow),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.tap(tileFinder(label));
  await tester.pumpAndSettle();
}

bool saveEnabled(WidgetTester tester) =>
    tester
        .widget<PrimaryButton>(find.widgetWithText(PrimaryButton, 'Save'))
        .onPressed !=
    null;

/// The row's categories, built or not: it scrolls sideways.
List<String> tileLabels(WidgetTester tester) => [
  for (final c
      in tester.widget<CategoryTileRow>(find.byType(CategoryTileRow)).choices)
    c.name,
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

Finder titleField() => find.byType(TextField).first;
Finder noteField() => find.byType(TextField).at(1);

Finder amountLabel(String amount) =>
    find.bySemanticsLabel('Total amount $amount');

void main() {
  group('S12 New expense', () {
    testWidgets('opens empty: RM 0.00, the keypad, Save off with a hint', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpAt(tester, Routes.add);
      expect(find.text('New expense'), findsOneWidget);
      expect(amountLabel('RM 0.00'), findsOneWidget);
      expect(find.text('Done'), findsNothing, reason: 'no keypad sheet');
      expect(find.bySemanticsLabel('Backspace'), findsOneWidget);
      expect(tileLabels(tester), [
        'Food',
        'Transport',
        'Shopping',
        'Bills',
        'Fun',
        'Health',
      ]);
      expect(find.text('What was it? (optional)'), findsOneWidget);
      expect(find.text('Today, 4 Nov'), findsOneWidget);
      expect(find.text('Add a note'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);
      expect(
        find.text('Enter an amount and pick a category to save'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('Save needs an amount and a category', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpAt(tester, Routes.add);
      await type(tester, '1250');
      expect(amountLabel('RM 12.50'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);
      await tapTile(tester, 'Food');
      expect(saveEnabled(tester), isTrue);
      expect(
        find.text('Enter an amount and pick a category to save'),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('saves the title and note, then closes', (tester) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '1250');
      await tapTile(tester, 'Food');
      await tester.enterText(titleField(), 'Nasi lemak');
      await tester.enterText(noteField(), 'With teh tarik');
      await save(tester);
      final saved = transactions.all.single;
      expect(saved.title, 'Nasi lemak');
      expect(saved.note, 'With teh tarik');
      expect(saved.amountMinor, 1250);
      expect(saved.occurredAt, now.toUtc());
      expect(find.byType(AddTransactionScreen), findsNothing);
    });

    testWidgets('a blank title uses the category name', (tester) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '500');
      await tapTile(tester, 'Transport');
      await save(tester);
      expect(transactions.all.single.title, 'Transport');
      expect(transactions.all.single.note, isNull);
    });

    testWidgets('the title stops at 40, the note at 200', (tester) async {
      await pumpAt(tester, Routes.add);
      expect(tester.widget<TextField>(titleField()).maxLength, 40);
      expect(tester.widget<TextField>(noteField()).maxLength, 200);
    });
  });

  group('Expense | Income', () {
    testWidgets('switching swaps the categories and clears the choice', (
      tester,
    ) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '1000');
      await tapTile(tester, 'Food');
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      expect(find.text('New income'), findsOneWidget);
      expect(tileLabels(tester), ['Salary', 'Gifts']);
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('?type=income opens New income', (tester) async {
      await pumpAt(tester, '${Routes.add}?type=income');
      expect(find.text('New income'), findsOneWidget);
    });

    testWidgets('saves income', (tester) async {
      await pumpAt(tester, '${Routes.add}?type=income');
      await type(tester, '480000');
      await tapTile(tester, 'Salary');
      await save(tester);
      expect(transactions.all.single.type, TransactionType.income);
    });
  });

  group('S46 Choose category', () {
    Future<void> openPicker(WidgetTester tester) async {
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
    }

    testWidgets('lists the type with limit status and "Added by you"', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.add,
        seed: () async {
          await categories.update(
            categories.byName('Food').copyWith(limitMinor: 40000),
          );
          await categories.update(
            categories.byName('Shopping').copyWith(limitMinor: 20000),
          );
          await categories.add(
            name: 'Coffee',
            type: TransactionType.expense,
            iconKey: CategoryIconKey.coffee,
            colorKey: CategoryColorKey.orange,
          );
          await transactions.add(
            amountMinor: 32800,
            type: TransactionType.expense,
            categoryId: categories.byName('Food').id,
            occurredAt: DateTime(2026, 11, 2, 12),
            title: 'x',
          );
          await transactions.add(
            amountMinor: 21000,
            type: TransactionType.expense,
            categoryId: categories.byName('Shopping').id,
            occurredAt: DateTime(2026, 11, 2, 12),
            title: 'x',
          );
        },
      );
      await openPicker(tester);
      expect(find.text('Choose category'), findsOneWidget);
      expect(find.text('Search categories'), findsOneWidget);
      expect(find.text('RM 72 left'), findsOneWidget);
      expect(find.text('Over by RM 10'), findsOneWidget);
      await tester.ensureVisible(find.text('Added by you'));
      expect(find.text('Added by you'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);
    });

    testWidgets('search narrows it; a pick selects and closes', (tester) async {
      await pumpAt(tester, Routes.add);
      await openPicker(tester);
      await tester.enterText(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(TextField),
        ),
        'he',
      );
      await tester.pump();
      expect(find.text('Health'), findsWidgets);
      expect(find.text('Shopping'), findsNothing);
      await tester.tap(find.text('Health').last);
      await tester.pumpAndSettle();
      expect(find.text('Choose category'), findsNothing);
      expect(tile(tester, 'Health').selected, isTrue);
    });

    testWidgets('archived categories are left out', (tester) async {
      await pumpAt(
        tester,
        Routes.add,
        seed: () => categories.archive(categories.byName('Fun').id),
      );
      await openPicker(tester);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Fun'),
        ),
        findsNothing,
      );
      expect(
        find.text(
          "Archived categories don't appear here. Restore them in Settings "
          '→ Categories.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('New category opens S24 and selects what it makes', (
      tester,
    ) async {
      await pumpAt(tester, Routes.add);
      await openPicker(tester);
      await tester.ensureVisible(find.text('New category'));
      await tester.tap(find.text('New category'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Pets');
      await tester.pump();
      await tester.tap(find.text('Create category'));
      await tester.pumpAndSettle();
      expect(categories.byName('Pets').type, TransactionType.expense);
      expect(tile(tester, 'Pets').selected, isTrue);
    });
  });

  group('date', () {
    testWidgets('the picker sets the date and keeps the time', (tester) async {
      await pumpAt(tester, Routes.add);
      await type(tester, '1000');
      await tapTile(tester, 'Food');
      await tester.tap(find.text('Today, 4 Nov'));
      await tester.pumpAndSettle();
      expect(find.text('Date'), findsOneWidget);

      await tester.tap(
        find.descendant(of: find.byType(BottomSheet), matching: find.text('5')),
      );
      await tester.pump();
      expect(find.text('Set 4 Nov'), findsOneWidget, reason: 'future day');
      await tester.tap(
        find.descendant(of: find.byType(BottomSheet), matching: find.text('2')),
      );
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
      await tester.tap(find.text('Today, 4 Nov'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(BottomSheet), matching: find.text('3')),
      );
      await tester.pump();
      await tester.tap(find.text('Set 3 Nov'));
      await tester.pumpAndSettle();
      expect(find.text('Yesterday, 3 Nov'), findsOneWidget);
    });
  });

  group('S45 Edit transaction', () {
    testWidgets('opens filled in, with Delete and the date and time', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpAt(
        tester,
        Routes.editTransaction(1),
        seed: () async {
          final lunch = await seedLunch();
          await transactions.update(lunch.copyWith(note: 'With teh tarik'));
        },
      );
      expect(find.text('Edit transaction'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(amountLabel('RM 12.50'), findsOneWidget);
      expect(tile(tester, 'Food').selected, isTrue);
      expect(find.text('Nasi lemak'), findsOneWidget);
      expect(find.text('With teh tarik'), findsOneWidget);
      expect(find.text('4 Nov, 08:15'), findsOneWidget);
      expect(saveEnabled(tester), isTrue);
      handle.dispose();
    });

    testWidgets('saving updates the same transaction', (tester) async {
      await pumpAt(tester, Routes.editTransaction(1), seed: seedLunch);
      await type(tester, '0');
      await tapTile(tester, 'Transport');
      await tester.enterText(titleField(), 'Taxi');
      await save(tester);

      final saved = transactions.all.single;
      expect(saved.id, 1);
      expect(saved.amountMinor, 12500);
      expect(saved.categoryId, categories.byName('Transport').id);
      expect(saved.title, 'Taxi');
      expect(saved.occurredAt, DateTime(2026, 11, 4, 8, 15).toUtc());
    });

    testWidgets('a title that was the category name shows blank', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.editTransaction(1),
        seed: () => seedLunch(title: 'Food'),
      );
      final field = tester.widget<TextField>(titleField());
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
    await tapTile(tester, 'Transport');
    await tester.enterText(titleField(), 'Grab to KLCC');
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
      final card =
          tester
                  .widget<Container>(
                    find
                        .ancestor(
                          of: find.text('TOTAL AMOUNT'),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(card.color, colors.surface);
      final selected = tester.widget<AnimatedContainer>(
        find.descendant(
          of: tileFinder('Food'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect((selected.decoration! as BoxDecoration).color, colors.ink);
      expect(tester.widget<Text>(find.text('12')).style!.color, colors.ink);
    });
  }
}
