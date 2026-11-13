import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/day_selector.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/month_setup_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/presentation/month_start_screen.dart';
import 'package:ctrl_spend/features/settings/presentation/settings_screen.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';

/// 4 Nov 2026, 9:00, the designs' "today".
final now = DateTime(2026, 11, 4, 9);

late FakePreferencesRepository prefs;
late FakeCategoryRepository categories;
late ProviderContainer container;

Future<void> pumpAt(
  WidgetTester tester,
  String route, {
  Preferences initial = const Preferences(
    userName: 'Alex',
    onboardingComplete: true,
    monthStartDay: DayOfMonth(15),
    monthlyBudgetMinor: 200000,
  ),
  Future<void> Function()? seed,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  prefs = FakePreferencesRepository(initial);
  categories = FakeCategoryRepository();
  await seed?.call();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(preferences: prefs, categories: categories),
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

ListGroupRow row(WidgetTester tester, String title) => tester.widget(
  find.byWidgetPredicate((w) => w is ListGroupRow && w.title == title),
);

DaySelector day(WidgetTester tester, String label) => tester.widget(
  find.byWidgetPredicate((w) => w is DaySelector && w.label == label),
);

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(PrimaryButton, 'Save'));
  // Let the save start before settling, or settle can return first.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

void main() {
  group('S21 Settings', () {
    testWidgets('shows the profile and rows with their values', (tester) async {
      await pumpAt(
        tester,
        Routes.settings,
        seed: () => categories.archive(categories.byName('Gifts').id),
      );
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Data stored on this phone'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(row(tester, 'Month starts on').value, '15th');
      expect(row(tester, 'Theme').value, 'System');
      expect(row(tester, 'Currency').value, 'RM');
      expect(row(tester, 'Categories').value, '8', reason: 'with archived');
      expect(find.text('Export to CSV'), findsOneWidget);
      expect(find.text('Import from CSV'), findsOneWidget);
    });

    testWidgets('v1.1 rows are hidden', (tester) async {
      await pumpAt(tester, Routes.settings);
      expect(find.text('App lock'), findsNothing);
      expect(find.text('Recurring bills'), findsNothing);
      expect(find.text('Savings goals'), findsNothing);
    });

    testWidgets('every row can be tapped', (tester) async {
      await pumpAt(tester, Routes.settings);
      expect(row(tester, 'Month starts on').onTap, isNotNull);
      expect(row(tester, 'Categories').onTap, isNotNull);
      expect(row(tester, 'Theme').onTap, isNotNull);
      expect(row(tester, 'Currency').onTap, isNotNull);
      expect(row(tester, 'Export to CSV').onTap, isNotNull);
      expect(row(tester, 'Import from CSV').onTap, isNotNull);
    });

    testWidgets('the last day shows as "Last day"', (tester) async {
      await pumpAt(
        tester,
        Routes.settings,
        initial: const Preferences(
          onboardingComplete: true,
          monthStartDay: LastDayOfMonth(),
        ),
      );
      expect(row(tester, 'Month starts on').value, 'Last day');
    });

    testWidgets('the name sheet saves a trimmed name', (tester) async {
      await pumpAt(tester, Routes.settings);
      await tester.tap(find.text('Alex'));
      await tester.pumpAndSettle();
      expect(find.text('Your name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  Alexandra  ');
      await tester.pump();
      await tapSave(tester);
      expect((await prefs.read()).userName, 'Alexandra');
      expect(find.text('Alexandra'), findsOneWidget);
    });

    testWidgets('a blank name can not be saved; 30 characters at most', (
      tester,
    ) async {
      await pumpAt(tester, Routes.settings);
      await tester.tap(find.text('Alex'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      final save = tester.widget<PrimaryButton>(
        find.widgetWithText(PrimaryButton, 'Save'),
      );
      expect(save.onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'A' * 40);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'A' * SettingsScreen.nameMaxLength,
      );
    });
  });

  group('S32 Month start', () {
    testWidgets('shows the saved day and both periods', (tester) async {
      await pumpAt(tester, Routes.monthStart);
      expect(
        find.text(
          'Pick the day your budget resets. Most people choose payday.',
        ),
        findsOneWidget,
      );
      expect(day(tester, '15').selected, isTrue);
      expect(day(tester, '1').selected, isFalse);
      expect(find.text('15 Oct – 14 Nov'), findsOneWidget);
      expect(find.text('15 Nov – 14 Dec'), findsOneWidget);
    });

    testWidgets('picking a day updates the previews but saves only on Save', (
      tester,
    ) async {
      await pumpAt(tester, Routes.monthStart);
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(day(tester, '1').selected, isTrue);
      expect(find.text('1 Nov – 30 Nov'), findsOneWidget);
      expect(find.text('1 Dec – 31 Dec'), findsOneWidget);
      expect((await prefs.read()).monthStartDay, const DayOfMonth(15));

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect((await prefs.read()).monthStartDay, const DayOfMonth(15));
    });

    testWidgets('Last day of the month', (tester) async {
      await pumpAt(tester, Routes.monthStart);
      await tester.tap(find.text('Last day of the month'));
      await tester.pumpAndSettle();
      expect(find.text('31 Oct – 29 Nov'), findsOneWidget);
      expect(find.text('30 Nov – 30 Dec'), findsOneWidget);
      await tapSave(tester);
      expect((await prefs.read()).monthStartDay, const LastDayOfMonth());
    });

    testWidgets('saving recalculates the period on Home', (tester) async {
      await pumpAt(tester, Routes.monthStart);
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tapSave(tester);
      expect(find.byType(MonthStartScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('1 NOV – 30 NOV'), findsOneWidget);
    });

    testWidgets('days read as ordinals', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpAt(tester, Routes.monthStart);
      expect(find.bySemanticsLabel('22nd'), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets("S04's Other opens S32 and comes back with the day", (
    tester,
  ) async {
    await pumpAt(tester, Routes.onboardingMonth, initial: const Preferences());
    expect(find.byType(MonthSetupScreen), findsOneWidget);
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    expect(find.byType(MonthStartScreen), findsOneWidget);
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tapSave(tester);
    expect(find.byType(MonthSetupScreen), findsOneWidget);
    expect((await prefs.read()).monthStartDay, const DayOfMonth(10));
    expect(find.text('10 Oct – 9 Nov · 5 days left'), findsOneWidget);
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('S21 and S32 use the theme in ${theme.name} mode', (
      tester,
    ) async {
      await pumpAt(
        tester,
        Routes.settings,
        initial: Preferences(
          userName: 'Alex',
          onboardingComplete: true,
          monthStartDay: const DayOfMonth(15),
          theme: theme,
        ),
      );
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(SettingsScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      await tester.tap(find.text('Month starts on'));
      await tester.pumpAndSettle();
      final selected = tester.widget<Material>(
        find
            .ancestor(of: find.text('15'), matching: find.byType(Material))
            .first,
      );
      expect(selected.color, colors.ink);
      expect(tester.getSize(find.byType(DaySelector).first).height, 44);
    });
  }
}
