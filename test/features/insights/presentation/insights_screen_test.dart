import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/pill_button.dart';
import 'package:ctrl_spend/features/insights/presentation/category_share_card.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_screen.dart';
import 'package:ctrl_spend/features/insights/presentation/spending_donut.dart';
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

/// 4 Nov 2026, 9:00, the designs' "today"; the period is 15 Oct – 14 Nov.
final now = DateTime(2026, 11, 4, 9);

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpInsights(
  WidgetTester tester, {
  AppTheme theme = AppTheme.system,
  int? budget = 200000,
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
  container.read(appRouterProvider).go(Routes.insights);
  await tester.pumpAndSettle();
}

Future<void> spend(
  int minor,
  String category, {
  DateTime? at,
  TransactionType type = TransactionType.expense,
  String? title,
}) => transactions.add(
  amountMinor: minor,
  type: type,
  categoryId: categories.byName(category).id,
  occurredAt: at ?? DateTime(2026, 11, 2, 12),
  title: title ?? category,
);

/// The design's month: RM 760 over four categories.
Future<void> designMonth() async {
  await spend(32800, 'Food');
  await spend(21000, 'Shopping');
  await spend(11600, 'Transport');
  await spend(6800, 'Bills');
  await spend(3800, 'Fun');
}

List<CategoryShareCard> cards(WidgetTester tester) => tester
    .widgetList<CategoryShareCard>(find.byType(CategoryShareCard))
    .toList();

void main() {
  group('S18 Insights · Month', () {
    testWidgets('opens on Month with the period total', (tester) async {
      await pumpInsights(tester, seed: designMonth);
      expect(find.text('Insights'), findsWidgets);
      expect(
        tester.getSemantics(find.text('Month')),
        isSemantics(label: 'Month', isSelected: true, isButton: true),
      );
      expect(find.text('Spent 15 Oct – 14 Nov'), findsOneWidget);
      expect(find.text('RM 760.00'), findsOneWidget);
      expect(find.text('SPENDING CATEGORIES'), findsOneWidget);
    });

    testWidgets('ranks categories, shares adding up to 100', (tester) async {
      await pumpInsights(tester, seed: designMonth);
      final shown = cards(tester);
      expect(
        [for (final c in shown) c.category.name],
        ['Food', 'Shopping', 'Transport', 'Bills', 'Fun'],
      );
      expect([for (final c in shown) c.percent], [43, 28, 15, 9, 5]);
      expect(
        [for (final c in shown) c.amount],
        ['RM 328', 'RM 210', 'RM 116', 'RM 68', 'RM 38'],
      );
      expect(find.text('43%'), findsOneWidget);
      expect(find.text('RM 328'), findsOneWidget);
    });

    testWidgets('the ring reads every category share', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpInsights(tester, seed: designMonth);
      expect(
        find.bySemanticsLabel(
          'Spent 15 Oct – 14 Nov, RM 760.00. Spending by category: '
          'Food 43%, RM 328; Shopping 28%, RM 210; Transport 15%, RM 116; '
          'Bills 9%, RM 68; Fun 5%, RM 38',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Food 43%, RM 328'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('leaves out income and other periods', (tester) async {
      await pumpInsights(
        tester,
        seed: () async {
          await spend(5000, 'Food');
          await spend(480000, 'Salary', type: TransactionType.income);
          // 14 Oct is the previous period.
          await spend(9900, 'Shopping', at: DateTime(2026, 10, 14, 12));
        },
      );
      expect([for (final c in cards(tester)) c.category.name], ['Food']);
      expect(find.text('RM 50.00'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('an archived category keeps its share', (tester) async {
      await pumpInsights(
        tester,
        seed: () async {
          await designMonth();
          await categories.archive(categories.byName('Fun').id);
        },
      );
      expect([for (final c in cards(tester)) c.category.name], contains('Fun'));
    });

    testWidgets('updates when an expense is added', (tester) async {
      await pumpInsights(tester, seed: designMonth);
      await spend(4000, 'Fun');
      await tester.pumpAndSettle();
      expect(find.text('RM 800.00'), findsOneWidget);
    });
  });

  group('S40 Insights · No data', () {
    testWidgets('shows the empty ring and copy', (tester) async {
      await pumpInsights(tester);
      expect(find.text('Spent'), findsOneWidget);
      expect(find.text('RM 0'), findsOneWidget);
      expect(find.text('Not enough data yet'), findsOneWidget);
      expect(
        find.text("Charts appear once you've logged a few days of spending."),
        findsOneWidget,
      );
      expect(find.byType(CategoryShareCard), findsNothing);
    });

    testWidgets('income alone is still no data', (tester) async {
      await pumpInsights(
        tester,
        seed: () => spend(480000, 'Salary', type: TransactionType.income),
      );
      expect(find.text('Not enough data yet'), findsOneWidget);
    });

    testWidgets('Add an expense opens Add transaction', (tester) async {
      await pumpInsights(tester);
      await tester.tap(find.widgetWithText(PillButton, 'Add an expense'));
      await tester.pumpAndSettle();
      expect(find.byType(AddTransactionScreen), findsOneWidget);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpInsights(tester, theme: theme, seed: designMonth);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(InsightsScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(CategoryShareCard),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((card.decoration! as BoxDecoration).color, colors.surface);
      expect(find.byType(SpendingDonut), findsOneWidget);
    });
  }
}
