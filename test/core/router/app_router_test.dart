import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/widgets/app_shell.dart';
import 'package:ctrl_spend/core/widgets/app_shell_tab.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/onboarding/presentation/how_it_works_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_category_repository.dart';
import '../../helpers/fake_preferences_repository.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester, {bool onboarded = true}) async {
    container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(
          FakePreferencesRepository(Preferences(onboardingComplete: onboarded)),
        ),
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    // Past the splash screen.
    await tester.pumpAndSettle();
  }

  Finder title(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Finder tab(String label) =>
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == label);

  group('onboarding redirect', () {
    testWidgets('sends a new user to Welcome', (tester) async {
      await pumpApp(tester, onboarded: false);

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets('a new user cannot open the app tabs directly', (tester) async {
      await pumpApp(tester, onboarded: false);

      container.read(appRouterProvider).go(Routes.budgets);
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('finishing onboarding saves it and lands on Home', (
      tester,
    ) async {
      await pumpApp(tester, onboarded: false);
      container.read(appRouterProvider).go(Routes.onboardingDone);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to dashboard'));
      await tester.pumpAndSettle();

      expect(title('Home'), findsOneWidget);
      final prefs = await container.read(preferencesRepositoryProvider).read();
      expect(prefs.onboardingComplete, isTrue);
    });

    testWidgets('an onboarded user cannot go back to onboarding', (
      tester,
    ) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go(Routes.onboardingHow);
      await tester.pumpAndSettle();

      expect(title('Home'), findsOneWidget);
      expect(find.byType(HowItWorksScreen), findsNothing);
    });
  });

  testWidgets('tabs switch between the four branches', (tester) async {
    await pumpApp(tester);

    for (final label in ['Activity', 'Budgets', 'Insights', 'Home']) {
      await tester.tap(tab(label));
      await tester.pumpAndSettle();
      expect(title(label), findsOneWidget);
    }
  });

  testWidgets('add button opens Add transaction and close returns', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(tab('Budgets'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();
    expect(title('Add transaction'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(title('Budgets'), findsOneWidget);
  });

  testWidgets('avatar opens Settings and back returns Home', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(title('Settings'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(title('Home'), findsOneWidget);
  });
}
