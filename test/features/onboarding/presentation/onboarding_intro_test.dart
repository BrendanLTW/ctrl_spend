import 'dart:async';

import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/brand_colors.dart';
import 'package:ctrl_spend/core/widgets/app_shell.dart';
import 'package:ctrl_spend/features/onboarding/presentation/how_it_works_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/name_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/splash_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';

/// Settings that load only when [load] is called.
class _SlowPreferences implements PreferencesRepository {
  final _loaded = Completer<Preferences>();

  void load([Preferences prefs = const Preferences()]) =>
      _loaded.complete(prefs);

  @override
  Stream<Preferences> watch() => Stream.fromFuture(_loaded.future);

  @override
  Future<Preferences> read() => _loaded.future;

  @override
  Future<void> update(Preferences Function(Preferences) change) async {}
}

Future<void> pumpApp(
  WidgetTester tester,
  PreferencesRepository prefs, {
  bool settle = true,
}) async {
  final container = ProviderContainer(
    overrides: fakeRepositories(preferences: prefs),
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  if (settle) await tester.pumpAndSettle();
}

Color? scaffoldColor(WidgetTester tester, Type screen) => tester
    .widget<Scaffold>(
      find.descendant(of: find.byType(screen), matching: find.byType(Scaffold)),
    )
    .backgroundColor;

void main() {
  group('S01 Splash', () {
    testWidgets('shows the brand, tagline and footer', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, FakePreferencesRepository(), settle: false);
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text("Know what's left to spend."), findsOneWidget);
      expect(find.text('by BrendanLTW', findRichText: true), findsOneWidget);
      // The whole splash is one tap target, read as one label.
      expect(
        find.bySemanticsLabel(
          RegExp(r'^ctrlSpend\n.*by BrendanLTW$', dotAll: true),
        ),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      handle.dispose();
    });

    testWidgets('moves on by itself after the loading bar', (tester) async {
      await pumpApp(tester, FakePreferencesRepository(), settle: false);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('a tap moves on at once', (tester) async {
      await pumpApp(tester, FakePreferencesRepository(), settle: false);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byType(SplashScreen));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(WelcomeScreen), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('waits for settings before moving on', (tester) async {
      final prefs = _SlowPreferences();
      await pumpApp(tester, prefs, settle: false);
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byType(SplashScreen));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SplashScreen), findsOneWidget);

      prefs.load(const Preferences(onboardingComplete: true));
      await tester.pumpAndSettle();
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('an onboarded user goes straight to Home', (tester) async {
      await pumpApp(
        tester,
        FakePreferencesRepository(const Preferences(onboardingComplete: true)),
      );
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });

    for (final (theme, background) in [
      (AppTheme.light, BrandColors.navy),
      (AppTheme.dark, AppColors.dark.ground),
    ]) {
      testWidgets('is navy in ${theme.name} mode', (tester) async {
        await pumpApp(
          tester,
          FakePreferencesRepository(Preferences(theme: theme)),
          settle: false,
        );
        // Until the stored theme loads, the default (system) theme shows.
        // then MaterialApp animates the theme change for 200 ms.
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 300));
        expect(scaffoldColor(tester, SplashScreen), background);
        await tester.pumpAndSettle();
      });
    }
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    group('in ${theme.name} mode', () {
      Future<void> start(WidgetTester tester) =>
          pumpApp(tester, FakePreferencesRepository(Preferences(theme: theme)));

      testWidgets('S02 Welcome shows the preview and pitch', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        expect(scaffoldColor(tester, WelcomeScreen), colors.ground);
        expect(
          find.text("Know what's left to spend, every day."),
          findsOneWidget,
        );
        expect(
          find.text(
            'Set one monthly budget, log what you spend, and ctrlSpend keeps '
            'count.',
          ),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Dashboard preview: RM 1,240.00 left to spend'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<Text>(find.text("Know what's left to spend, every day."))
              .style!
              .color,
          colors.ink,
        );
        handle.dispose();
      });

      testWidgets('Get started → S03, Back returns', (tester) async {
        await start(tester);
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();
        expect(find.byType(HowItWorksScreen), findsOneWidget);
        expect(scaffoldColor(tester, HowItWorksScreen), colors.ground);

        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.byType(WelcomeScreen), findsOneWidget);
      });

      testWidgets('S03 lists the basics and the privacy promise', (
        tester,
      ) async {
        await start(tester);
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();
        for (final text in [
          'How it works',
          "Three steps, then you're in control.",
          'THE BASICS',
          'Set one monthly budget',
          "Pick what you want to spend. Home shows what's left.",
          'Log spending in seconds',
          'Tap +, type the amount, pick a category. Done.',
          'See where it goes',
          'Spot the categories that eat your budget.',
          'YOUR PRIVACY',
          'Stays on this phone',
          'No account, no bank login. Export a CSV whenever you like.',
        ]) {
          expect(find.text(text), findsOneWidget, reason: text);
        }
      });
    });
  }

  group('navigation', () {
    Future<void> toHowItWorks(WidgetTester tester) async {
      await pumpApp(tester, FakePreferencesRepository());
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
    }

    testWidgets('Skip the tour skips S03', (tester) async {
      await pumpApp(tester, FakePreferencesRepository());
      await tester.tap(find.text('Skip the tour'));
      await tester.pumpAndSettle();
      expect(find.byType(NameScreen), findsOneWidget);
      expect(find.byType(HowItWorksScreen), findsNothing);
    });

    testWidgets('S03 Continue and Skip both go to the next step', (
      tester,
    ) async {
      for (final action in ['Continue', 'Skip']) {
        await toHowItWorks(tester);
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(find.byType(NameScreen), findsOneWidget, reason: action);
      }
    });

    testWidgets('Back from the next step returns to S03', (tester) async {
      await toHowItWorks(tester);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(HowItWorksScreen), findsOneWidget);
    });
  });
}
