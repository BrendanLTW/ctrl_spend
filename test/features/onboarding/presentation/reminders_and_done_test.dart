import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_shell.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/step_indicator.dart';
import 'package:ctrl_spend/features/onboarding/presentation/all_set_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/budget_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/category_limits_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/month_setup_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/name_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/reminders_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/presentation/add_transaction_screen.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';

// intl writes times with a narrow no-break space before AM/PM (Unicode CLDR).
late FakePreferencesRepository prefs;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpAt(
  WidgetTester tester,
  String route, {
  Preferences initial = const Preferences(),
  Map<String, int> limits = const {},
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  prefs = FakePreferencesRepository(initial);
  categories = FakeCategoryRepository();
  for (final MapEntry(:key, :value) in limits.entries) {
    await categories.update(categories.byName(key).copyWith(limitMinor: value));
  }
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(preferences: prefs, categories: categories),
      clockProvider.overrideWithValue(() => DateTime(2026, 11, 4, 9)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  container.read(appRouterProvider).go(route);
  await tester.pumpAndSettle();
}

AppToggle toggle(WidgetTester tester, String title) => tester.widget<AppToggle>(
  find.byWidgetPredicate(
    (w) => w is AppToggle && w.semanticLabel.startsWith('$title, '),
  ),
);

String rowValue(WidgetTester tester, String label) {
  final row = find.ancestor(of: find.text(label), matching: find.byType(Row));
  final texts = tester.widgetList<Text>(
    find.descendant(of: row.first, matching: find.byType(Text)),
  );
  return texts.last.data!;
}

Future<void> next(WidgetTester tester, [String label = 'Continue']) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('S07 Stay on track', () {
    testWidgets('is step 5 of 5 with the copy and sample', (tester) async {
      await pumpAt(tester, Routes.onboardingReminders);
      final step = tester.widget<StepIndicator>(find.byType(StepIndicator));
      expect((step.current, step.total), (5, 5));
      expect(find.text('Stay on track'), findsOneWidget);
      expect(
        find.text(
          "You have RM 72 left for Food this period. Log today's spending?",
        ),
        findsOneWidget,
      );
      expect(find.text('Every day at 9:00\u202fPM'), findsOneWidget);
      expect(find.text('When a budget reaches 80% and 100%'), findsOneWidget);
      expect(find.text('Sunday evenings'), findsOneWidget);
    });

    testWidgets('toggles show the defaults and save when flipped', (
      tester,
    ) async {
      await pumpAt(tester, Routes.onboardingReminders);
      expect(toggle(tester, 'Daily reminder').value, isTrue);
      expect(toggle(tester, 'Budget alerts').value, isTrue);
      expect(toggle(tester, 'Weekly summary').value, isFalse);

      await tester.tap(find.byWidget(toggle(tester, 'Daily reminder')));
      await tester.pumpAndSettle();
      // Tapping the row's text flips it too.
      await tester.tap(find.text('Weekly summary'));
      await tester.pumpAndSettle();

      final saved = await prefs.read();
      expect(saved.dailyReminderOn, isFalse);
      expect(saved.weeklySummaryOn, isTrue);
      expect(toggle(tester, 'Daily reminder').value, isFalse);
      expect(toggle(tester, 'Weekly summary').value, isTrue);
    });

    testWidgets('the reminder time comes from settings', (tester) async {
      await pumpAt(
        tester,
        Routes.onboardingReminders,
        initial: const Preferences(dailyReminderMinutes: 20 * 60 + 30),
      );
      expect(find.text('Every day at 8:30\u202fPM'), findsOneWidget);
    });

    for (final action in ['Turn on notifications', 'Not now']) {
      testWidgets('$action goes to S08', (tester) async {
        await pumpAt(tester, Routes.onboardingReminders);
        await next(tester, action);
        expect(find.byType(AllSetScreen), findsOneWidget);
      });
    }

    testWidgets('each row reads as one toggle', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpAt(tester, Routes.onboardingReminders);
      expect(
        find.bySemanticsLabel('Daily reminder, Every day at 9:00\u202fPM'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Daily reminder'), findsNothing);
      handle.dispose();
    });
  });

  group('S08 You are all set', () {
    testWidgets('summarises the setup', (tester) async {
      await pumpAt(
        tester,
        Routes.onboardingDone,
        initial: const Preferences(
          monthlyBudgetMinor: 200000,
          monthStartDay: DayOfMonth(15),
        ),
        limits: {'Food': 40000, 'Transport': 30000, 'Shopping': 20000},
      );
      expect(find.text("You're all set"), findsOneWidget);
      expect(
        find.text(
          "Add what you've spent since 15 Oct to see what's really left this "
          'period.',
        ),
        findsOneWidget,
      );
      expect(rowValue(tester, 'Monthly budget'), 'RM 2,000');
      expect(rowValue(tester, 'Month starts on'), '15th');
      expect(rowValue(tester, 'Category limits'), '3 of 6');
      expect(rowValue(tester, 'Reminders'), 'Daily, 9:00\u202fPM');
    });

    for (final (name, initial, reminders) in [
      (
        'weekly, last day',
        const Preferences(
          monthStartDay: LastDayOfMonth(),
          dailyReminderOn: false,
          weeklySummaryOn: true,
        ),
        'Weekly, Sunday',
      ),
      (
        'alerts only',
        const Preferences(dailyReminderOn: false),
        'Budget alerts only',
      ),
      (
        'off',
        const Preferences(dailyReminderOn: false, budgetAlertsOn: false),
        'Off',
      ),
    ]) {
      testWidgets('no budget, reminders $name', (tester) async {
        await pumpAt(tester, Routes.onboardingDone, initial: initial);
        expect(rowValue(tester, 'Monthly budget'), 'Not set');
        expect(rowValue(tester, 'Reminders'), reminders);
        if (initial.monthStartDay is LastDayOfMonth) {
          expect(rowValue(tester, 'Month starts on'), 'Last day');
          expect(find.textContaining('since 31 Oct'), findsOneWidget);
        }
      });
    }

    testWidgets('Go to dashboard finishes onboarding on Home', (tester) async {
      await pumpAt(tester, Routes.onboardingDone);
      await next(tester, 'Go to dashboard');
      expect((await prefs.read()).onboardingComplete, isTrue);
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('Add your first expense opens Add over Home', (tester) async {
      await pumpAt(tester, Routes.onboardingDone);
      await next(tester, 'Add your first expense');
      expect((await prefs.read()).onboardingComplete, isTrue);
      expect(find.byType(AddTransactionScreen), findsOneWidget);

      // New entries open the keypad first; Done closes it.
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
    });
  });

  testWidgets('a full run from Welcome to Home, then Back keeps it all', (
    tester,
  ) async {
    await pumpAt(tester, Routes.onboarding);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await next(tester, 'Get started');
    await next(tester);

    expect(find.byType(NameScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pump();
    await next(tester);

    expect(find.byType(MonthSetupScreen), findsOneWidget);
    await tester.tap(find.text('15th'));
    await tester.pumpAndSettle();
    await next(tester);

    expect(find.byType(BudgetScreen), findsOneWidget);
    for (final key in '200000'.split('')) {
      await tester.tap(find.widgetWithText(InkWell, key).last);
      await tester.pump();
    }
    await next(tester);

    expect(find.byType(CategoryLimitsScreen), findsOneWidget);
    await next(tester, 'Skip');

    expect(find.byType(RemindersScreen), findsOneWidget);
    await tester.tap(find.text('Weekly summary'));
    await tester.pumpAndSettle();
    await next(tester, 'Not now');

    expect(find.byType(AllSetScreen), findsOneWidget);
    expect(rowValue(tester, 'Monthly budget'), 'RM 2,000');
    expect(rowValue(tester, 'Month starts on'), '15th');

    // Back through every step: each shows what was entered.
    // The system back action, as Android's back gesture sends; S08 has
    // no back button of its own.
    Future<void> back() async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    await back();
    expect(toggle(tester, 'Weekly summary').value, isTrue);
    await back();
    expect(find.byType(CategoryLimitsScreen), findsOneWidget);
    await back();
    expect(find.text('RM 2,000.00', findRichText: true), findsOneWidget);
    await back();
    expect(find.text('15 Oct – 14 Nov · 10 days left'), findsOneWidget);
    await back();
    expect(find.text('Alex'), findsOneWidget);

    // And forward again to finish.
    await next(tester);
    await next(tester);
    await next(tester);
    await next(tester);
    await next(tester, 'Not now');
    await next(tester, 'Go to dashboard');
    expect(find.byType(AppShell), findsOneWidget);
    final saved = await prefs.read();
    expect(saved.userName, 'Alex');
    expect(saved.monthStartDay, const DayOfMonth(15));
    expect(saved.monthlyBudgetMinor, 200000);
    expect(saved.weeklySummaryOn, isTrue);
    expect(saved.onboardingComplete, isTrue);
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('S07 and S08 use the theme in ${theme.name} mode', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.onboardingReminders,
        initial: Preferences(theme: theme),
      );
      expect(
        tester.widget<Text>(find.text('Daily reminder')).style!.color,
        colors.ink,
      );
      container.read(appRouterProvider).go(Routes.onboardingDone);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text("You're all set")).style!.color,
        colors.ink,
      );
      final button = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(button.color, colors.ink);
    });
  }
}
