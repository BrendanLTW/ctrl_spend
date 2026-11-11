import 'dart:async';

import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/add_transaction_screen.dart';
import 'package:ctrl_spend/features/transactions/presentation/budget_impact_card.dart';
import 'package:ctrl_spend/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
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

Future<void> pumpApp(
  WidgetTester tester, {
  Preferences prefs = const Preferences(
    onboardingComplete: true,
    monthStartDay: DayOfMonth(15),
    monthlyBudgetMinor: 200000,
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

/// Opens S41 for [id] over Home.
Future<void> openDetail(WidgetTester tester, [int id = 1]) async {
  // push() completes only when the screen closes, so don't wait for it.
  unawaited(container.read(appRouterProvider).push(Routes.transaction(id)));
  await tester.pumpAndSettle();
}

Future<Transaction> add(
  int minor,
  String title, {
  String category = 'Food',
  DateTime? at,
  TransactionType type = TransactionType.expense,
  String? note,
}) => transactions.add(
  amountMinor: minor,
  type: type,
  categoryId: categories.byName(category).id,
  occurredAt: at ?? DateTime(2026, 11, 4, 8, 12),
  title: title,
  note: note,
);

Future<void> setLimit(String category, int minor) =>
    categories.update(categories.byName(category).copyWith(limitMinor: minor));

BudgetImpactCard impact(WidgetTester tester) =>
    tester.widget<BudgetImpactCard>(find.byType(BudgetImpactCard));

void main() {
  testWidgets('shows the summary and details of an expense', (tester) async {
    await pumpApp(tester, seed: () => add(1250, 'Nasi lemak'));
    await openDetail(tester);
    expect(find.text('Transaction'), findsOneWidget);
    expect(find.text('Nasi lemak'), findsOneWidget);
    final amount = tester.widget<Text>(find.text('${minus}RM 12.50'));
    expect(amount.style!.color, AppColors.light.negative);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('DETAILS'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Wed, 4 Nov · 8:12 AM'), findsOneWidget);
    expect(find.text('Note'), findsNothing, reason: 'no note yet');
  });

  testWidgets('a note gets its own row', (tester) async {
    await pumpApp(
      tester,
      seed: () => add(1250, 'Nasi lemak', note: 'Breakfast near office'),
    );
    await openDetail(tester);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Breakfast near office'), findsOneWidget);
  });

  group('budget impact', () {
    testWidgets('the category against its limit, amber at 82%', (tester) async {
      await pumpApp(
        tester,
        seed: () async {
          await setLimit('Food', 40000);
          await add(1250, 'Nasi lemak');
          await add(31550, 'Groceries', at: DateTime(2026, 10, 20));
        },
      );
      await openDetail(tester);
      expect(find.text('BUDGET IMPACT'), findsOneWidget);
      expect(impact(tester).name, 'Food');
      expect(find.text('RM 72 left'), findsOneWidget);
      expect(find.text('RM 328 of RM 400 this period'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('RM 72 left')).style!.color,
        AppColors.light.warning,
      );
      expect(
        tester.widget<AppProgressBar>(find.byType(AppProgressBar)).value,
        0.82,
      );
    });

    testWidgets('over the limit reads "Over by" in red', (tester) async {
      await pumpApp(
        tester,
        seed: () async {
          await setLimit('Food', 30000);
          await add(32800, 'Groceries');
        },
      );
      await openDetail(tester);
      expect(find.text('Over by RM 28'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Over by RM 28')).style!.color,
        AppColors.light.negative,
      );
    });

    testWidgets('no category limit falls back to the monthly budget', (
      tester,
    ) async {
      await pumpApp(
        tester,
        seed: () async {
          await add(1820, 'Grab', category: 'Transport');
          await add(74180, 'Rent', category: 'Bills');
        },
      );
      await openDetail(tester);
      expect(impact(tester).name, 'Monthly budget');
      expect(find.text('RM 1,240 left'), findsOneWidget);
      expect(find.text('RM 760 of RM 2,000 this period'), findsOneWidget);
    });

    testWidgets('nothing to measure hides the section', (tester) async {
      await pumpApp(
        tester,
        prefs: const Preferences(onboardingComplete: true),
        seed: () => add(1250, 'Nasi lemak'),
      );
      await openDetail(tester);
      expect(find.text('BUDGET IMPACT'), findsNothing);
    });

    testWidgets('an earlier period is named', (tester) async {
      await pumpApp(
        tester,
        seed: () async {
          await setLimit('Food', 40000);
          await add(1250, 'Lunch', at: DateTime(2026, 10, 10, 13));
        },
      );
      await openDetail(tester);
      expect(
        find.text('RM 12.50 of RM 400 in 15 Sep – 14 Oct'),
        findsOneWidget,
      );
    });
  });

  testWidgets('income is green with no budget impact', (tester) async {
    await pumpApp(
      tester,
      seed: () => add(
        480000,
        'Salary',
        category: 'Salary',
        type: TransactionType.income,
      ),
    );
    await openDetail(tester);
    final amount = tester.widget<Text>(find.text('+RM 4,800.00'));
    expect(amount.style!.color, AppColors.light.positive);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('BUDGET IMPACT'), findsNothing);
  });

  testWidgets('Edit opens S13; saving shows the change here', (tester) async {
    await pumpApp(tester, seed: () => add(1250, 'Nasi lemak'));
    await openDetail(tester);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Roti canai');
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    expect(find.text('Roti canai'), findsOneWidget);
  });

  group('delete', () {
    testWidgets('Cancel keeps it', (tester) async {
      await pumpApp(tester, seed: () => add(1250, 'Nasi lemak'));
      await openDetail(tester);
      await tester.tap(find.text('Delete transaction'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this transaction?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(transactions.all, hasLength(1));
      expect(find.byType(TransactionDetailScreen), findsOneWidget);
    });

    testWidgets('confirming deletes and returns to Home', (tester) async {
      await pumpApp(tester, seed: () => add(1250, 'Nasi lemak'));
      await openDetail(tester);
      await tester.tap(find.text('Delete transaction'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AppDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(transactions.all, isEmpty);
      expect(find.byType(TransactionDetailScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('deleting from S13 closes S41 too', (tester) async {
      await pumpApp(tester, seed: () => add(1250, 'Nasi lemak'));
      await openDetail(tester);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AppDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AddTransactionScreen), findsNothing);
      expect(find.byType(TransactionDetailScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });

  testWidgets('a Home row opens its detail', (tester) async {
    await pumpApp(tester, seed: () => add(1250, 'Nasi lemak'));
    await tester.tap(find.byType(TransactionRow));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpApp(
        tester,
        prefs: Preferences(
          onboardingComplete: true,
          monthlyBudgetMinor: 200000,
          theme: theme,
        ),
        seed: () => add(1250, 'Nasi lemak'),
      );
      await openDetail(tester);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(TransactionDetailScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      expect(
        tester.widget<Text>(find.text('${minus}RM 12.50')).style!.color,
        colors.negative,
      );
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(BudgetImpactCard),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((card.decoration! as BoxDecoration).color, colors.surface);
    });
  }
}
