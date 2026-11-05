import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester, {bool onboarded = true}) async {
    container = ProviderContainer();
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

  group('onboarding redirect', () {
    testWidgets('sends a new user to onboarding', (tester) async {
      await pumpApp(tester, onboarded: false);

      expect(find.text('Finish onboarding'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
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

    for (final tab in ['Activity', 'Budgets', 'Insights', 'Home']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await tester.pumpAndSettle();
      expect(title(tab), findsOneWidget);
    }
  });

  testWidgets('add button opens Add transaction and close returns', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Budgets'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();
    expect(title('Add transaction'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

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
