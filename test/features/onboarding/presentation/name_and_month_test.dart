import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_text_field.dart';
import 'package:ctrl_spend/core/widgets/day_selector.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/step_indicator.dart';
import 'package:ctrl_spend/features/onboarding/presentation/budget_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/month_setup_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/name_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';

/// 4 Nov 2026, the designs' "today".
final today = DateTime(2026, 11, 4, 9);

late FakePreferencesRepository prefs;
late ProviderContainer container;

Future<void> pumpAt(
  WidgetTester tester,
  String route, {
  Preferences initial = const Preferences(),
}) async {
  prefs = FakePreferencesRepository(initial);
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(preferences: prefs),
      clockProvider.overrideWithValue(() => today),
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

bool continueEnabled(WidgetTester tester) =>
    tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed != null;

DaySelector selector(WidgetTester tester, String label) =>
    tester.widget<DaySelector>(find.widgetWithText(DaySelector, label));

void main() {
  group('S03a Your name', () {
    testWidgets('is step 1 of 5 with the copy and an empty field', (
      tester,
    ) async {
      await pumpAt(tester, Routes.onboardingName);
      expect(find.text('What should we call you?'), findsOneWidget);
      expect(
        find.text("It's how ctrlSpend says hi. Your name stays on this phone."),
        findsOneWidget,
      );
      expect(find.text('First name'), findsOneWidget);
      final step = tester.widget<StepIndicator>(find.byType(StepIndicator));
      expect((step.current, step.total), (1, 5));
    });

    testWidgets('Continue needs a non-blank name', (tester) async {
      await pumpAt(tester, Routes.onboardingName);
      expect(continueEnabled(tester), isFalse);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(continueEnabled(tester), isFalse);
      await tester.enterText(find.byType(TextField), ' A ');
      await tester.pump();
      expect(continueEnabled(tester), isTrue);
    });

    testWidgets('saves the trimmed name and moves to S04', (tester) async {
      await pumpAt(tester, Routes.onboardingName);
      await tester.enterText(find.byType(TextField), '  Alex  ');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect((await prefs.read()).userName, 'Alex');
      expect(find.byType(MonthSetupScreen), findsOneWidget);
    });

    testWidgets('stops at 30 characters', (tester) async {
      await pumpAt(tester, Routes.onboardingName);
      await tester.enterText(find.byType(TextField), 'A' * 40);
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'A' * NameScreen.maxLength);
    });

    testWidgets('the keyboard opens with the field focused', (tester) async {
      await pumpAt(tester, Routes.onboardingName);
      expect(tester.testTextInput.isVisible, isTrue);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofocus, isTrue);
    });

    testWidgets('shows a saved name', (tester) async {
      await pumpAt(
        tester,
        Routes.onboardingName,
        initial: const Preferences(userName: 'Alex'),
      );
      expect(find.text('Alex'), findsOneWidget);
      expect(continueEnabled(tester), isTrue);
    });
  });

  group('S04 Set up your month', () {
    testWidgets('is step 2 of 5 with the currency and default start', (
      tester,
    ) async {
      await pumpAt(tester, Routes.onboardingMonth);
      final step = tester.widget<StepIndicator>(find.byType(StepIndicator));
      expect((step.current, step.total), (2, 5));
      expect(find.text('Malaysian Ringgit'), findsOneWidget);
      expect(find.text('RM'), findsOneWidget);
      expect(selector(tester, '1st').selected, isTrue);
      expect(selector(tester, 'Other').selected, isFalse);
      expect(find.text('1 Nov – 30 Nov · 26 days left'), findsOneWidget);
    });

    testWidgets('choosing 15th saves it and updates the preview', (
      tester,
    ) async {
      await pumpAt(tester, Routes.onboardingMonth);
      await tester.tap(find.text('15th'));
      await tester.pumpAndSettle();
      expect((await prefs.read()).monthStartDay, const DayOfMonth(15));
      expect(selector(tester, '15th').selected, isTrue);
      expect(selector(tester, '1st').selected, isFalse);
      expect(find.text('15 Oct – 14 Nov · 10 days left'), findsOneWidget);
    });

    testWidgets('another start day shows as Other', (tester) async {
      for (final start in [const DayOfMonth(10), const LastDayOfMonth()]) {
        await pumpAt(
          tester,
          Routes.onboardingMonth,
          initial: Preferences(monthStartDay: start),
        );
        expect(selector(tester, 'Other').selected, isTrue, reason: '$start');
        for (final quick in ['1st', '15th', '25th']) {
          expect(selector(tester, quick).selected, isFalse);
        }
      }
    });

    testWidgets('shows the saved currency', (tester) async {
      await pumpAt(
        tester,
        Routes.onboardingMonth,
        initial: const Preferences(currencyCode: 'SGD'),
      );
      expect(find.text('Singapore Dollar'), findsOneWidget);
      expect(find.text(r'S$'), findsOneWidget);
    });

    testWidgets('on the last day of a period it says "Last day"', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.onboardingMonth,
        initial: const Preferences(monthStartDay: DayOfMonth(5)),
      );
      expect(find.text('5 Oct – 4 Nov · Last day'), findsOneWidget);
    });

    testWidgets('Continue goes to the next step', (tester) async {
      await pumpAt(tester, Routes.onboardingMonth);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetScreen), findsOneWidget);
    });
  });

  testWidgets('Back from S04 keeps the name; returning keeps the start day', (
    tester,
  ) async {
    await pumpAt(tester, Routes.onboarding);
    await tester.tap(find.text('Skip the tour'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25th'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(NameScreen), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(selector(tester, '25th').selected, isTrue);
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('both screens use the theme in ${theme.name} mode', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.onboardingName,
        initial: Preferences(theme: theme),
      );
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(AppTextField),
          matching: find.byType(TextField),
        ),
      );
      expect(field.decoration!.fillColor, colors.surface);
      expect(
        tester.widget<Text>(find.text('What should we call you?')).style!.color,
        colors.ink,
      );

      container.read(appRouterProvider).go(Routes.onboardingMonth);
      await tester.pumpAndSettle();
      expect(selector(tester, '1st').selected, isTrue);
      final selected = tester.widget<Material>(
        find
            .ancestor(of: find.text('1st'), matching: find.byType(Material))
            .first,
      );
      expect(selected.color, colors.ink);
    });
  }
}
