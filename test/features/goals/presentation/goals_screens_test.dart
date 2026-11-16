import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/detail_rows.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:ctrl_spend/features/goals/presentation/add_goal_screen.dart';
import 'package:ctrl_spend/features/goals/presentation/goal_card.dart';
import 'package:ctrl_spend/features/goals/presentation/goal_detail_screen.dart';
import 'package:ctrl_spend/features/goals/presentation/savings_goals_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_goal_repository.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../transactions/presentation/add_transaction_screen_test.dart'
    show done, type;

/// 4 Nov 2026; with start day 15 the period is 15 Oct – 14 Nov.
final now = DateTime(2026, 11, 4, 9);

late FakeGoalRepository goals;
late ProviderContainer container;

Future<void> pumpApp(
  WidgetTester tester, {
  String location = Routes.goals,
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed = designGoals,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  goals = FakeGoalRepository();
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
        goals: goals,
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
  unawaited(container.read(appRouterProvider).push(location));
  await tester.pumpAndSettle();
}

Future<Goal> addGoal(
  String name,
  int target,
  DateTime month,
  CategoryIconKey icon,
  List<(int, String, DateTime)> contributions,
) async {
  final goal = await goals.add(
    name: name,
    iconKey: icon,
    targetMinor: target,
    targetMonth: month,
    createdAt: contributions.isEmpty ? now : contributions.first.$3,
  );
  for (final (minor, label, date) in contributions) {
    await goals.addMoney(goal.id, amountMinor: minor, label: label, date: date);
  }
  return goal;
}

/// S29 and S30's goals: Bali trip RM 3,200 of RM 5,000 by Mar 2027 (RM 400
/// added this period), MacBook Air RM 2,500 of RM 5,500, and Raya clothes
/// completed.
Future<void> designGoals() async {
  await addGoal(
    'MacBook Air',
    550000,
    DateTime(2027, 6),
    CategoryIconKey.laptop,
    [(250000, 'Savings', DateTime(2026, 8, 2))],
  );
  await addGoal(
    'Bali trip',
    500000,
    DateTime(2027, 3),
    CategoryIconKey.travel,
    [
      (200000, 'Savings', DateTime(2026, 8, 3)),
      (50000, 'From salary', DateTime(2026, 9, 3)),
      (30000, 'Bonus top-up', DateTime(2026, 10, 4)),
      (40000, 'From salary', DateTime(2026, 11, 3)),
    ],
  );
  await addGoal(
    'Raya clothes',
    80000,
    DateTime(2026, 3),
    CategoryIconKey.gift,
    [(80000, 'Savings', DateTime(2026, 2, 20))],
  );
}

Goal goalNamed(String name) => goals.all.firstWhere((g) => g.name == name);

Future<void> openGoal(WidgetTester tester, String name) async {
  await tester.tap(
    find.byWidgetPredicate((w) => w is GoalCard && w.goal.name == name),
  );
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

/// Taps S60/S61's confirm button ("Add RM 400" or "Withdraw").
Future<void> confirmSheet(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(PrimaryButton),
    ),
  );
  await tester.pumpAndSettle();
}

PrimaryButton sheetButton(WidgetTester tester) => tester.widget(
  find.descendant(
    of: find.byType(BottomSheet),
    matching: find.byType(PrimaryButton),
  ),
);

/// Opens S62 from S30's •••.
Future<void> openOptions(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('More options'));
  await tester.pumpAndSettle();
}

ListGroupRow contribution(WidgetTester tester, int i) => tester
    .widgetList<ListGroupRow>(
      find.descendant(
        of: find.byType(GoalDetailScreen),
        matching: find.byType(ListGroupRow),
      ),
    )
    .elementAt(i);

void main() {
  group('S29 Savings goals', () {
    testWidgets('totals every goal and nets this period', (tester) async {
      await pumpApp(tester);
      expect(find.text('TOTAL SAVED'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'RM 6,500\.00')), findsWidgets);
      expect(find.text('+RM 400 this month'), findsOneWidget);
    });

    testWidgets('a withdrawal this period can make it negative', (
      tester,
    ) async {
      await pumpApp(
        tester,
        seed: () async {
          await designGoals();
          await goals.withdraw(
            goalNamed('Bali trip').id,
            amountMinor: 45000,
            label: 'x',
            date: DateTime(2026, 11, 4),
          );
        },
      );
      expect(find.text('−RM 50 this month'), findsOneWidget);
    });

    testWidgets('lists active goals soonest first, with type and progress', (
      tester,
    ) async {
      await pumpApp(tester);
      final cards = tester.widgetList<GoalCard>(find.byType(GoalCard));
      expect(
        [for (final c in cards) c.goal.name],
        ['Bali trip', 'MacBook Air'],
      );
      expect(find.text('Travel · by Mar 2027'), findsOneWidget);
      expect(find.text('Gadget · by Jun 2027'), findsOneWidget);
      expect(find.text('64%'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      expect(find.text('RM 3,200'), findsOneWidget);
      expect(find.text('RM 1,800'), findsOneWidget);
    });

    testWidgets('completed goals sit behind a row that expands', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.scrollUntilVisible(find.text('1 completed goal'), 200);
      expect(find.text('Raya clothes · RM 800'), findsOneWidget);
      expect(find.text('Raya clothes'), findsNothing);
      await tapText(tester, '1 completed goal');
      await tester.scrollUntilVisible(find.text('Completed 20 Feb'), 200);
      expect(
        find.byWidgetPredicate(
          (w) => w is GoalCard && w.goal.name == 'Raya clothes',
        ),
        findsOneWidget,
        reason: 'the same card as an active goal',
      );
      await tester.ensureVisible(find.text('Raya clothes'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Raya clothes');
      expect(find.byType(GoalDetailScreen), findsOneWidget);
      expect(find.text('Goal reached'), findsOneWidget);
      expect(find.text('You reached RM 800.'), findsOneWidget);
    });

    testWidgets('with no goals shows the empty state, which adds one', (
      tester,
    ) async {
      await pumpApp(tester, seed: null);
      expect(find.text('Start your first goal'), findsOneWidget);
      expect(
        find.text(
          'Pick a target and a date, and ctrlSpend shows how much to put '
          "aside each month. Savings don't count as spending.",
        ),
        findsOneWidget,
      );
      await tapText(tester, 'Create a goal');
      expect(find.byType(AddGoalScreen), findsOneWidget);
    });
  });

  group('S30 Goal detail', () {
    testWidgets('shows saved, the monthly amount and the contributions', (
      tester,
    ) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      expect(find.text('RM 3,200'), findsOneWidget);
      expect(find.text('of RM 5,000'), findsOneWidget);
      expect(find.text('RM 1,800 to go'), findsOneWidget);
      expect(find.text('Target Mar 2027'), findsOneWidget);
      expect(find.text('On track'), findsOneWidget);
      expect(
        find.text('Save RM 450 a month to reach it by March.'),
        findsOneWidget,
      );
      final first = contribution(tester, 0);
      expect(
        (first.title, first.subtitle, first.value),
        ('From salary', '3 Nov', '+RM 400'),
      );
      expect(first.valueColor, AppColors.light.positive);
      expect(contribution(tester, 1).title, 'Bonus top-up');
    });

    testWidgets('Add money saves the amount and the note', (tester) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      await tapText(tester, 'Add money');
      expect(find.text('From salary'), findsWidgets, reason: 'the default');
      expect(
        find.text(
          'Money you save doesn\'t count as spending, so "Left to spend" '
          'stays the same.',
        ),
        findsOneWidget,
      );
      await type(tester, '10000');
      expect(find.text('Add RM 100'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Birthday money');
      await confirmSheet(tester);
      final added = goals.contributions.first;
      expect((added.amountMinor, added.label), (10000, 'Birthday money'));
      expect(added.date, DateTime(2026, 11, 4));
      expect(find.text('RM 3,300'), findsOneWidget);
    });

    testWidgets('the sheet can switch to Withdraw and pick an earlier day', (
      tester,
    ) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      await tapText(tester, 'Add money');
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Withdraw'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('From salary'),
        ),
        findsNothing,
        reason: 'cleared',
      );
      await type(tester, '5000');
      await tester.tap(find.bySemanticsLabel('Today, 4 Nov'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet).last,
          matching: find.text('2'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet).last,
          matching: find.byType(PrimaryButton),
        ),
      );
      await tester.pumpAndSettle();
      await confirmSheet(tester);
      final taken = goals.contributions.firstWhere((c) => c.amountMinor < 0);
      expect((taken.amountMinor, taken.label), (-5000, 'Withdrawn'));
      expect(taken.date, DateTime(2026, 11, 2));
    });

    testWidgets('Withdraw is capped at what is saved', (tester) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      await tapText(tester, 'Withdraw');
      await type(tester, '320001');
      expect(
        find.text('You can withdraw up to RM 3,200, the amount saved so far.'),
        findsOneWidget,
      );
      expect(sheetButton(tester).onPressed, isNull);
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.bySemanticsLabel('Backspace'));
        await tester.pump();
      }
      await type(tester, '20000');
      await confirmSheet(tester);
      final row = contribution(tester, 0);
      expect((row.title, row.value), ('Withdrawn', '−RM 200'));
      expect(row.valueColor, AppColors.light.ink);
    });

    testWidgets('reaching the target completes the goal', (tester) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      await tapText(tester, 'Add money');
      await type(tester, '180000');
      await confirmSheet(tester);
      expect(find.text('Goal reached'), findsOneWidget);
      expect(goalNamed('Bali trip').completedAt, DateTime(2026, 11, 4));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('2 completed goals'), 200);
      expect(find.text('2 completed goals'), findsOneWidget);
    });

    testWidgets('behind the plan in the target month: the rest is due', (
      tester,
    ) async {
      await pumpApp(
        tester,
        seed: () => addGoal(
          'Laptop',
          300000,
          DateTime(2026, 11),
          CategoryIconKey.laptop,
          [(100000, 'x', DateTime(2026, 9))],
        ),
      );
      await openGoal(tester, 'Laptop');
      expect(find.text('Behind'), findsOneWidget);
      expect(
        find.text('Save RM 2,000 a month to catch up by November.'),
        findsOneWidget,
      );
    });

    testWidgets('past the target date', (tester) async {
      await pumpApp(
        tester,
        seed: () => addGoal(
          'Laptop',
          300000,
          DateTime(2026, 10),
          CategoryIconKey.laptop,
          [(100000, 'x', DateTime(2026, 9))],
        ),
      );
      await openGoal(tester, 'Laptop');
      expect(find.text('Past the target date'), findsOneWidget);
      expect(find.text('Add RM 2,000 to reach it.'), findsOneWidget);
    });

    testWidgets('Withdraw is off with nothing saved', (tester) async {
      await pumpApp(
        tester,
        seed: () =>
            addGoal('Car', 1000000, DateTime(2028), CategoryIconKey.car, []),
      );
      await openGoal(tester, 'Car');
      expect(
        find.text('Nothing saved yet. Add money to start.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextLink>(find.widgetWithText(TextLink, 'Withdraw'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('••• offers Edit, Mark as completed and Delete', (
      tester,
    ) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      await openOptions(tester);
      expect(find.text('Edit goal'), findsOneWidget);
      expect(find.text('Name, target, date and icon'), findsOneWidget);
      expect(find.text('Mark as completed'), findsOneWidget);
      expect(
        find.text(
          "Removes the goal and its 4 contributions. Your spending isn't "
          'affected.',
        ),
        findsOneWidget,
      );
      await tapText(tester, 'Cancel');
      expect(find.byType(GoalDetailScreen), findsOneWidget);
    });

    testWidgets('Edit goal opens S31, which no longer deletes', (tester) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      await openOptions(tester);
      await tapText(tester, 'Edit goal');
      expect(find.byType(AddGoalScreen), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('Mark as completed moves it to completed goals', (
      tester,
    ) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      await openOptions(tester);
      await tapText(tester, 'Mark as completed');
      expect(find.byType(SavingsGoalsScreen), findsOneWidget);
      expect(goalNamed('Bali trip').completedAt, isNotNull);
      await tester.scrollUntilVisible(find.text('2 completed goals'), 200);
      expect(find.text('2 completed goals'), findsOneWidget);
      // Completed already: the option isn't offered again.
      await tapText(tester, '2 completed goals');
      await tester.scrollUntilVisible(find.text('Bali trip'), 200);
      await tester.ensureVisible(find.text('Bali trip'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Bali trip');
      await openOptions(tester);
      expect(find.text('Mark as completed'), findsNothing);
    });

    testWidgets('Delete goal removes it and its contributions', (tester) async {
      await pumpApp(tester);
      await openGoal(tester, 'Bali trip');
      await openOptions(tester);
      await tapText(tester, 'Delete goal');
      expect(find.byType(SavingsGoalsScreen), findsOneWidget);
      expect(goals.all.map((g) => g.name), isNot(contains('Bali trip')));
      expect(
        goals.contributions.where((c) => c.label == 'Bonus top-up'),
        isEmpty,
      );
    });
  });

  group('S31 New goal', () {
    Future<void> openNew(WidgetTester tester) async {
      await pumpApp(tester, seed: null);
      // The header's Add: at 200% text S63's button is below the fold.
      await tapText(tester, 'Add');
    }

    Future<void> pickMonth(WidgetTester tester, String label) async {
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is DetailRow && w.label == 'Target date',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pump();
    }

    testWidgets('shows the monthly amount as it is filled in', (tester) async {
      await openNew(tester);
      expect(find.text('Done'), findsOneWidget, reason: 'keypad sheet');
      await type(tester, '800000');
      await done(tester);
      expect(find.text('TARGET AMOUNT'), findsOneWidget);
      await pickMonth(tester, 'December 2027');
      await tapText(tester, 'Set Dec 2027');
      expect(find.text('RM 616 a month'), findsOneWidget);
      expect(find.text('to reach RM 8,000 by December 2027'), findsOneWidget);
    });

    testWidgets('Create needs an amount and a name, and saves the goal', (
      tester,
    ) async {
      await openNew(tester);
      await type(tester, '800000');
      await done(tester);
      PrimaryButton create() =>
          tester.widget(find.widgetWithText(PrimaryButton, 'Create goal'));
      expect(create().onPressed, isNull);
      await tester.enterText(find.byType(TextField), ' Car down payment ');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Car'));
      await tester.pump();
      await tester.tap(find.widgetWithText(PrimaryButton, 'Create goal'));
      await tester.pumpAndSettle();
      expect(find.byType(SavingsGoalsScreen), findsOneWidget);
      final goal = goals.all.single;
      expect(goal.name, 'Car down payment');
      expect(goal.targetMinor, 800000);
      expect(goal.iconKey, CategoryIconKey.car);
      expect(goal.targetMonth, DateTime(2027, 11), reason: 'a year ahead');
    });

    testWidgets('the month picker starts at this month', (tester) async {
      await openNew(tester);
      await done(tester);
      await pickMonth(tester, 'November 2027');
      await tester.tap(find.byTooltip('Previous year'));
      await tester.pump();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('October 2026'))
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
      );
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byTooltip('Previous year'),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('goal screens use the theme in ${theme.name} mode', (
      tester,
    ) async {
      await pumpApp(tester, theme: theme);
      Color? background(Type screen) => tester
          .widget<Scaffold>(
            find.descendant(
              of: find.byType(screen),
              matching: find.byType(Scaffold),
            ),
          )
          .backgroundColor;
      expect(background(SavingsGoalsScreen), colors.ground);
      await openGoal(tester, 'Bali trip');
      expect(background(GoalDetailScreen), colors.ground);
    });
  }
}
