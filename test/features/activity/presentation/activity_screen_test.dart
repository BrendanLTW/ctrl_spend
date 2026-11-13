import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/budget_hero.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/filter_chips.dart';
import 'package:ctrl_spend/core/widgets/swipe_to_delete.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/activity/presentation/activity_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fake_transaction_repository.dart';

const String minus = MoneyFormatter.minus;

/// 4 Nov 2026, 9:00, the designs' "today".
final now = DateTime(2026, 11, 4, 9);

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpActivity(
  WidgetTester tester, {
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  transactions = FakeTransactionRepository();
  categories = FakeCategoryRepository();
  transactions.categoryName = (id) => categories.byId(id)?.name;
  await seed?.call();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: FakePreferencesRepository(
          Preferences(
            onboardingComplete: true,
            monthStartDay: const DayOfMonth(15),
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
  container.read(appRouterProvider).go(Routes.activity);
  await tester.pumpAndSettle();
}

Future<Transaction> add(
  int minor,
  String title,
  DateTime at, {
  String category = 'Food',
  TransactionType type = TransactionType.expense,
}) => transactions.add(
  amountMinor: minor,
  type: type,
  categoryId: categories.byName(category).id,
  occurredAt: at,
  title: title,
);

/// The design's sample days.
Future<void> seedDesign() async {
  await add(1250, 'Nasi lemak', DateTime(2026, 11, 4, 8, 40));
  await add(
    1820,
    'Grab to KLCC',
    DateTime(2026, 11, 4, 8, 30),
    category: 'Transport',
  );
  await add(
    480000,
    'Salary',
    DateTime(2026, 11, 3, 10),
    category: 'Salary',
    type: TransactionType.income,
  );
  await add(
    13900,
    'TNB electricity',
    DateTime(2026, 11, 1, 9),
    category: 'Bills',
  );
}

Future<void> swipeLeft(WidgetTester tester, String title, double dx) async {
  await tester.drag(find.widgetWithText(TransactionRow, title), Offset(dx, 0));
  await tester.pumpAndSettle();
}

/// The Delete button behind a revealed row.
Finder get deleteButton => find.descendant(
  of: find.byType(SwipeToDelete),
  matching: find.text('Delete'),
);

void main() {
  testWidgets("groups by day with each day's net", (tester) async {
    final handle = tester.ensureSemantics();
    await pumpActivity(tester, seed: seedDesign);
    expect(find.text('Activity'), findsWidgets);
    for (final (label, header) in [
      ('TODAY', 'Today, ${minus}RM 30.70'),
      ('YESTERDAY, 3 NOV', 'Yesterday, 3 Nov, +RM 4,800.00'),
      ('SUN, 1 NOV', 'Sun, 1 Nov, ${minus}RM 139.00'),
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
      expect(find.bySemanticsLabel(header), findsOneWidget, reason: header);
    }
    handle.dispose();
  });

  testWidgets('rows are captioned by category, income as "Income"', (
    tester,
  ) async {
    await pumpActivity(tester, seed: seedDesign);
    final rows = tester
        .widgetList<TransactionRow>(find.byType(TransactionRow))
        .toList();
    expect(
      [for (final r in rows) r.title],
      ['Nasi lemak', 'Grab to KLCC', 'Salary', 'TNB electricity'],
    );
    expect(
      [for (final r in rows) r.caption],
      ['Food', 'Transport', 'Income', 'Bills'],
    );
    expect(rows.every((r) => r.compact), isTrue);
  });

  testWidgets('a row opens its detail', (tester) async {
    await pumpActivity(tester, seed: seedDesign);
    await tester.tap(find.text('Grab to KLCC'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
  });

  testWidgets('no transactions shows the empty state', (tester) async {
    await pumpActivity(tester);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No transactions yet'), findsOneWidget);
  });

  testWidgets('an archived category keeps its history here (FR-06)', (
    tester,
  ) async {
    await pumpActivity(
      tester,
      seed: () async {
        await seedDesign();
        await categories.archive(categories.byName('Bills').id);
      },
    );
    final row = tester.widget<TransactionRow>(
      find.widgetWithText(TransactionRow, 'TNB electricity'),
    );
    expect(row.caption, 'Bills');
  });

  group('search and filters', () {
    Future<void> search(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pumpAndSettle();
    }

    Future<void> chip(WidgetTester tester, String label) async {
      final finder = find.descendant(
        of: find.byType(
          FilterChips<({TransactionType? type, int? categoryId})>,
        ),
        matching: find.text(label),
      );
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    List<String> titles(WidgetTester tester) => [
      for (final r in tester.widgetList<TransactionRow>(
        find.byType(TransactionRow),
      ))
        r.title,
    ];

    testWidgets('the chips: All, the types, then categories', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      final row = tester
          .widget<FilterChips<({TransactionType? type, int? categoryId})>>(
            find.byType(
              FilterChips<({TransactionType? type, int? categoryId})>,
            ),
          );
      expect(
        [for (final c in row.chips) c.label],
        [
          'All',
          'Expense',
          'Income',
          'Food',
          'Transport',
          'Shopping',
          'Bills',
          'Fun',
          'Health',
          'Salary',
          'Gifts',
        ],
      );
    });

    testWidgets('search matches title and category, ignoring case', (
      tester,
    ) async {
      await pumpActivity(tester, seed: seedDesign);
      await search(tester, 'NASI');
      expect(titles(tester), ['Nasi lemak']);
      await search(tester, 'transp');
      expect(titles(tester), ['Grab to KLCC']);
      expect(find.text('${minus}RM 18.20'), findsNWidgets(2), reason: 'net');
    });

    testWidgets('type and category chips filter', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      await chip(tester, 'Income');
      expect(titles(tester), ['Salary']);
      await chip(tester, 'Bills');
      expect(titles(tester), ['TNB electricity']);
      await chip(tester, 'All');
      expect(titles(tester), hasLength(4));
    });

    testWidgets('search and a chip combine', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      await chip(tester, 'Expense');
      await search(tester, 'a');
      expect(titles(tester), ['Nasi lemak', 'Grab to KLCC']);
    });

    testWidgets('no results in a chip offers Search all', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      await chip(tester, 'Expense');
      await search(tester, 'salary');
      expect(find.text('No results for “salary”'), findsOneWidget);
      expect(
        find.text(
          'Nothing matches in Expense. Try another word, or search all '
          'transactions.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Search all'));
      await tester.pumpAndSettle();
      expect(titles(tester), ['Salary']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'salary',
        reason: 'the search text stays',
      );
    });

    testWidgets('no results with All has no button', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      await search(tester, 'netflix');
      expect(find.text('No results for “netflix”'), findsOneWidget);
      expect(find.text('Nothing matches. Try another word.'), findsOneWidget);
      expect(find.text('Search all'), findsNothing);
    });

    testWidgets('an empty chip says nothing is there yet', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      await chip(tester, 'Health');
      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(find.text('No transactions in Health so far.'), findsOneWidget);
    });

    testWidgets('clearing the search brings everything back', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      await search(tester, 'nasi');
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(titles(tester), hasLength(4));
      expect(find.byTooltip('Clear search'), findsNothing);
    });

    testWidgets('no transactions at all ignores the filters', (tester) async {
      await pumpActivity(tester);
      await search(tester, 'x');
      expect(find.text('No transactions yet'), findsOneWidget);
    });
  });

  group('swipe to delete', () {
    testWidgets('a short drag snaps back', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      await swipeLeft(tester, 'Nasi lemak', -30);
      expect(deleteButton, findsNothing);
    });

    testWidgets('a long drag reveals Delete; tapping the row closes it', (
      tester,
    ) async {
      await pumpActivity(tester, seed: seedDesign);
      await swipeLeft(tester, 'Nasi lemak', -150);
      expect(deleteButton, findsOneWidget);
      await tester.tap(find.text('Nasi lemak'));
      await tester.pumpAndSettle();
      expect(deleteButton, findsNothing);
      expect(find.byType(TransactionDetailScreen), findsNothing);
    });

    testWidgets('Delete removes it and shows the toast', (tester) async {
      await pumpActivity(tester, seed: seedDesign);
      await swipeLeft(tester, 'Nasi lemak', -150);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      expect(find.text('Nasi lemak'), findsNothing);
      expect(transactions.all, hasLength(3));
      expect(find.text('Transaction deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('${minus}RM 18.20'), findsNWidgets(2), reason: 'net');
      hideAppToast();
    });

    testWidgets('Undo restores it exactly', (tester) async {
      late Transaction lunch;
      await pumpActivity(
        tester,
        seed: () async {
          await seedDesign();
          lunch = transactions.all.firstWhere((t) => t.title == 'Nasi lemak');
        },
      );
      await swipeLeft(tester, 'Nasi lemak', -150);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(transactions.all, contains(lunch));
      expect(find.text('Nasi lemak'), findsOneWidget);
      expect(find.text('Transaction deleted'), findsNothing);
    });

    testWidgets('after 5 seconds the toast goes and it stays deleted', (
      tester,
    ) async {
      await pumpActivity(tester, seed: seedDesign);
      await swipeLeft(tester, 'Nasi lemak', -150);
      await tester.tap(deleteButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Transaction deleted'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Transaction deleted'), findsNothing);
      expect(transactions.all, hasLength(3));
    });

    testWidgets('screen readers get a Delete action', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpActivity(tester, seed: seedDesign);
      final node = tester.getSemantics(find.byType(SwipeToDelete).first);
      const delete = CustomSemanticsAction(label: 'Delete');
      expect(node, isSemantics(customActions: [delete]));
      // The action calls the same onDelete as the Delete button above.
      handle.dispose();
    });
  });

  testWidgets('Home updates after a delete and an Undo', (tester) async {
    await pumpActivity(tester, seed: seedDesign);
    await swipeLeft(tester, 'Grab to KLCC', -150);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    container.read(appRouterProvider).go(Routes.home);
    await tester.pumpAndSettle();
    expect(
      tester.widget<BudgetHero>(find.byType(BudgetHero)).spentMinor,
      15150,
    );

    container.read(appRouterProvider).go(Routes.activity);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    container.read(appRouterProvider).go(Routes.home);
    await tester.pumpAndSettle();
    expect(
      tester.widget<BudgetHero>(find.byType(BudgetHero)).spentMinor,
      16970,
    );
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpActivity(tester, theme: theme, seed: seedDesign);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(ActivityScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      expect(
        tester.widget<Text>(find.text('TODAY')).style!.color,
        colors.muted,
      );
      await swipeLeft(tester, 'Nasi lemak', -150);
      final panel = tester.widget<Material>(
        find.ancestor(of: deleteButton, matching: find.byType(Material)).first,
      );
      expect(panel.color, AppColors.light.negative);
    });
  }
}
