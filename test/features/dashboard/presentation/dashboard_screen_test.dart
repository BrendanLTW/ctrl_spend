import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/budget_hero.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
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
import '../../../helpers/find_app_icon.dart';

const String minus = MoneyFormatter.minus;

/// 4 Nov 2026, 9:00, the designs' "today".
final now = DateTime(2026, 11, 4, 9);

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpHome(
  WidgetTester tester, {
  Preferences prefs = const Preferences(
    userName: 'Alex',
    monthStartDay: DayOfMonth(15),
    monthlyBudgetMinor: 200000,
    onboardingComplete: true,
  ),
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
        preferences: FakePreferencesRepository(prefs),
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
}

Future<void> spend(
  int minor,
  String title, {
  String category = 'Food',
  DateTime? at,
  TransactionType type = TransactionType.expense,
}) => transactions.add(
  amountMinor: minor,
  type: type,
  categoryId: categories.byName(category).id,
  occurredAt: at ?? now,
  title: title,
);

/// The design's sample: RM 760 spent, RM 4,800 income this period.
Future<void> seedDesign() async {
  await spend(1250, 'Nasi lemak', at: DateTime(2026, 11, 4, 8));
  await spend(1820, 'Grab to KLCC', category: 'Transport');
  await spend(
    480000,
    'Salary',
    category: 'Salary',
    type: TransactionType.income,
    at: DateTime(2026, 11, 3, 10),
  );
  await spend(72930, 'Groceries', at: DateTime(2026, 10, 20));
  // Last period: counted in Recent activities only if among the latest.
  await spend(5000, 'Old', at: DateTime(2026, 10, 10));
}

void main() {
  testWidgets('the header shows the period, greeting and actions', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text('15 OCT – 14 NOV'), findsOneWidget);
    expect(find.text('Hi, Alex'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.text('A'), findsOneWidget, reason: 'avatar initial');
  });

  testWidgets('without a name it greets "Hi there"', (tester) async {
    await pumpHome(tester, prefs: const Preferences(onboardingComplete: true));
    expect(find.text('Hi there'), findsOneWidget);
    expect(findAppIcon(AppIcon.user), findsOneWidget);
  });

  testWidgets('the hero, Spent and Income follow this period', (tester) async {
    await pumpHome(tester, seed: seedDesign);
    final hero = tester.widget<BudgetHero>(find.byType(BudgetHero));
    expect(hero.spentMinor, 76000);
    expect(hero.budgetMinor, 200000);
    expect(find.text('RM 1,240.00', findRichText: true), findsOneWidget);
    expect(find.text('RM 760', findRichText: true), findsOneWidget);
    expect(find.text('RM 4,800', findRichText: true), findsOneWidget);
  });

  testWidgets('recent activities show the latest three, captioned', (
    tester,
  ) async {
    await pumpHome(tester, seed: seedDesign);
    final rows = tester
        .widgetList<TransactionRow>(find.byType(TransactionRow))
        .toList();
    expect(
      [for (final r in rows) r.title],
      ['Grab to KLCC', 'Nasi lemak', 'Salary'],
    );
    expect(
      [for (final r in rows) r.caption],
      ['Today · Transport', 'Today · Food', 'Yesterday · Income'],
    );
    expect(find.text('${minus}RM 18.20'), findsOneWidget);
    expect(find.text('+RM 4,800.00'), findsOneWidget);
  });

  testWidgets('older entries show their date', (tester) async {
    await pumpHome(
      tester,
      seed: () => spend(900, 'Lunch', at: DateTime(2026, 10, 28, 13)),
    );
    expect(
      tester.widget<TransactionRow>(find.byType(TransactionRow)).caption,
      '28 Oct · Food',
    );
  });

  testWidgets('an archived category still names its entries', (tester) async {
    await pumpHome(
      tester,
      seed: () async {
        await spend(900, 'Movie', category: 'Fun');
        await categories.archive(categories.byName('Fun').id);
      },
    );
    expect(
      tester.widget<TransactionRow>(find.byType(TransactionRow)).caption,
      'Today · Fun',
    );
  });

  testWidgets('figures update as soon as a transaction is added', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text('RM 2,000.00', findRichText: true), findsOneWidget);
    await spend(184000, 'Rent');
    await tester.pumpAndSettle();
    expect(find.text('RM 160.00', findRichText: true), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('RM 1,840', findRichText: true), findsOneWidget);
  });

  testWidgets('the hero shows no-budget mode', (tester) async {
    await pumpHome(
      tester,
      prefs: const Preferences(
        userName: 'Alex',
        monthStartDay: DayOfMonth(15),
        onboardingComplete: true,
      ),
      seed: seedDesign,
    );
    expect(find.text('SPENT THIS PERIOD'), findsOneWidget);
    expect(find.text('Set a monthly budget'), findsOneWidget);
  });

  group('S10 first run', () {
    testWidgets('no transactions shows the empty state, no View all', (
      tester,
    ) async {
      await pumpHome(tester);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
      expect(
        find.text('Add what you spend and your budget updates as you go.'),
        findsOneWidget,
      );
      expect(find.text('View all'), findsNothing);
      expect(find.byType(TransactionRow), findsNothing);
      expect(find.text('RM 2,000.00', findRichText: true), findsOneWidget);
      expect(find.text('RM 0', findRichText: true), findsNWidgets(2));
    });

    testWidgets('Add your first expense opens Add, and close returns', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.ensureVisible(find.text('Add your first expense'));
      await tester.tap(find.text('Add your first expense'));
      await tester.pumpAndSettle();
      expect(find.byType(AddTransactionScreen), findsOneWidget);
      // New entries open the keypad first; Done closes it.
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('the first transaction replaces the empty state', (
      tester,
    ) async {
      await pumpHome(tester);
      await spend(1250, 'Nasi lemak');
      await tester.pumpAndSettle();
      expect(find.byType(EmptyState), findsNothing);
      expect(find.text('Nasi lemak'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);
    });

    testWidgets('an older period still counts, so no empty state', (
      tester,
    ) async {
      await pumpHome(
        tester,
        seed: () => spend(5000, 'Old', at: DateTime(2026, 10, 10)),
      );
      expect(find.byType(EmptyState), findsNothing);
      expect(find.text('RM 0', findRichText: true), findsNWidgets(2));
    });

    for (final (theme, colors) in [
      (AppTheme.light, AppColors.light),
      (AppTheme.dark, AppColors.dark),
    ]) {
      testWidgets('the empty card uses the theme in ${theme.name} mode', (
        tester,
      ) async {
        await pumpHome(
          tester,
          prefs: Preferences(
            monthlyBudgetMinor: 200000,
            onboardingComplete: true,
            theme: theme,
          ),
        );
        final card = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(EmptyState),
                matching: find.byType(Container),
              )
              .first,
        );
        expect((card.decoration! as BoxDecoration).color, colors.surface);
      });
    }
  });

  group('navigation', () {
    testWidgets('View all opens Activity', (tester) async {
      await pumpHome(tester, seed: () => spend(1250, 'Nasi lemak'));
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();
      expect(
        container
            .read(appRouterProvider)
            .routerDelegate
            .currentConfiguration
            .uri
            .path,
        Routes.activity,
      );
    });

    testWidgets('the hero opens Budgets', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text('LEFT TO SPEND'));
      await tester.pumpAndSettle();
      expect(
        container
            .read(appRouterProvider)
            .routerDelegate
            .currentConfiguration
            .uri
            .path,
        Routes.budgets,
      );
    });

    testWidgets('the avatar opens Settings and back returns', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsNothing);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpHome(
        tester,
        prefs: Preferences(
          userName: 'Alex',
          monthlyBudgetMinor: 200000,
          onboardingComplete: true,
          theme: theme,
        ),
        seed: seedDesign,
      );
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(DashboardScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      expect(
        tester.widget<Text>(find.text('Hi, Alex')).style!.color,
        colors.ink,
      );
    });
  }
}
