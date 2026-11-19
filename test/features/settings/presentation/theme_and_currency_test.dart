import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/widgets/app_radio.dart';
import 'package:ctrlspend/features/onboarding/presentation/month_setup_screen.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/features/settings/presentation/currency_screen.dart';
import 'package:ctrlspend/features/settings/presentation/theme_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'settings_screen_test.dart' show container, prefs, pumpAt, row;

ThemeMode appThemeMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

List<bool> radios(WidgetTester tester) => [
  for (final r in tester.widgetList<AppRadio>(find.byType(AppRadio)))
    r.selected,
];

Future<void> tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  group('S33 Theme', () {
    testWidgets('shows the three options and the note', (tester) async {
      await pumpAt(tester, Routes.theme);
      expect(find.text('Theme'), findsOneWidget);
      for (final label in ['Light', 'Dark', 'System']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(
        find.text(
          "System matches your phone's light or dark setting automatically.",
        ),
        findsOneWidget,
      );
      // System is the default.
      expect(radios(tester), [false, false, true]);
    });

    testWidgets('a choice saves at once and the app follows', (tester) async {
      await pumpAt(tester, Routes.theme);
      expect(appThemeMode(tester), ThemeMode.system);
      await tap(tester, 'Dark');
      expect((await prefs.read()).theme, AppTheme.dark);
      expect(appThemeMode(tester), ThemeMode.dark);
      expect(radios(tester), [false, true, false]);
      await tap(tester, 'Light');
      expect((await prefs.read()).theme, AppTheme.light);
      expect(appThemeMode(tester), ThemeMode.light);
    });

    testWidgets('S21 opens it and shows the choice', (tester) async {
      await pumpAt(tester, Routes.settings);
      await tap(tester, 'Theme');
      expect(find.byType(ThemeScreen), findsOneWidget);
      await tap(tester, 'Dark');
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(row(tester, 'Theme').value, 'Dark');
    });
  });

  group('S34 Currency', () {
    testWidgets('offers Malaysian Ringgit only, for now', (tester) async {
      await pumpAt(tester, Routes.currency);
      expect(find.text('SUGGESTED'), findsOneWidget);
      expect(find.text('Malaysian Ringgit'), findsOneWidget);
      expect(find.text('MYR · current'), findsOneWidget);
      expect(find.text('ALL CURRENCIES'), findsNothing);
      for (final name in ['Singapore Dollar', 'US Dollar', 'Euro']) {
        expect(find.text(name), findsNothing, reason: name);
      }
      expect(radios(tester), [true]);
      expect(
        find.text(
          'Switching currency changes the symbol only. '
          "Existing amounts aren't converted.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('search matches it by name, code or symbol', (tester) async {
      await pumpAt(tester, Routes.currency);
      Future<void> search(String query) async {
        await tester.enterText(find.byType(TextField), query);
        await tester.pump();
      }

      for (final query in ['ringgit', 'myr', 'rm']) {
        await search(query);
        expect(find.text('Malaysian Ringgit'), findsOneWidget, reason: query);
      }
      await search('dollar');
      expect(find.text('No currencies match “dollar”'), findsOneWidget);
    });

    testWidgets('S21 opens it and shows the symbol', (tester) async {
      await pumpAt(tester, Routes.settings);
      await tap(tester, 'Currency');
      expect(find.byType(CurrencyScreen), findsOneWidget);
      await tap(tester, 'Malaysian Ringgit');
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(row(tester, 'Currency').value, 'RM');
    });

    testWidgets('S04 opens it and shows the choice', (tester) async {
      await pumpAt(
        tester,
        Routes.onboardingMonth,
        initial: const Preferences(userName: 'Alex'),
      );
      await tap(tester, 'Malaysian Ringgit');
      expect(find.byType(CurrencyScreen), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(MonthSetupScreen), findsOneWidget);
      expect(find.text('Malaysian Ringgit'), findsOneWidget);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('both use the theme in ${theme.name} mode', (tester) async {
      await pumpAt(
        tester,
        Routes.currency,
        initial: Preferences(onboardingComplete: true, theme: theme),
      );
      Color? background(Type screen) => tester
          .widget<Scaffold>(
            find.descendant(
              of: find.byType(screen),
              matching: find.byType(Scaffold),
            ),
          )
          .backgroundColor;
      expect(background(CurrencyScreen), colors.ground);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      container.read(appRouterProvider).go(Routes.settings);
      await tester.pumpAndSettle();
      await tap(tester, 'Theme');
      expect(background(ThemeScreen), colors.ground);
    });
  }
}
