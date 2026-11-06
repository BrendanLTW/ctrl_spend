import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/widgets/app_shell.dart';
import 'package:ctrl_spend/core/widgets/app_shell_tab.dart';
import 'package:ctrl_spend/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_preferences_repository.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester, {bool onboarded = true}) async {
    container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(
          FakePreferencesRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    if (onboarded) {
      container.read(onboardingCompleteProvider.notifier).complete();
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.pumpAndSettle();
  }

  Finder title(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Finder tab(String label) =>
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == label);

  group('onboarding redirect', () {
    testWidgets('sends a new user to onboarding', (tester) async {
      await pumpApp(tester, onboarded: false);

      expect(find.text('Finish onboarding'), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets('finishing onboarding lands on Home', (tester) async {
      await pumpApp(tester, onboarded: false);

      await tester.tap(find.text('Finish onboarding'));
      await tester.pumpAndSettle();

      expect(title('Home'), findsOneWidget);
    });

    testWidgets('an onboarded user cannot go back to onboarding', (
      tester,
    ) async {
      await pumpApp(tester);

      container.read(appRouterProvider).go(Routes.onboarding);
      await tester.pumpAndSettle();

      expect(title('Home'), findsOneWidget);
      expect(find.text('Finish onboarding'), findsNothing);
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
