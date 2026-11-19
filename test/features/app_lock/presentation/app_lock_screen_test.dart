import 'dart:async';

import 'package:ctrlspend/core/period/clock.dart';
import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/widgets/app_toggle.dart';
import 'package:ctrlspend/core/widgets/list_group.dart';
import 'package:ctrlspend/features/app_lock/presentation/app_lock_screen.dart';
import 'package:ctrlspend/features/app_lock/presentation/app_switcher_guard.dart';
import 'package:ctrlspend/features/app_lock/presentation/lock_screen.dart';
import 'package:ctrlspend/features/app_lock/presentation/pin_flow_screen.dart';
import 'package:ctrlspend/features/app_lock/presentation/pin_pad.dart';
import 'package:ctrlspend/features/notifications/presentation/reminder_toggles.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_lock.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';

late FakePreferencesRepository prefs;
late FakePinStore pins;
late FakeDeviceAuth deviceAuth;
late FakeSecureWindow secureWindow;
DateTime now = DateTime(2026, 11, 4, 9);

/// Opens S37 with app lock [on] (and its PIN 2580) or off.
Future<void> pumpAppLock(
  WidgetTester tester, {
  bool on = false,
  bool biometrics = true,
  AppTheme theme = AppTheme.system,
  Preferences Function(Preferences)? tweak,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  now = DateTime(2026, 11, 4, 9);
  final initial = Preferences(
    userName: 'Alex',
    onboardingComplete: true,
    theme: theme,
    appLockOn: on,
  );
  prefs = FakePreferencesRepository(tweak?.call(initial) ?? initial);
  pins = FakePinStore(on ? '2580' : null);
  deviceAuth = FakeDeviceAuth(biometrics: biometrics);
  secureWindow = FakeSecureWindow();
  final container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: prefs,
        pin: pins,
        deviceAuth: deviceAuth,
        secureWindow: secureWindow,
      ),
      clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  // On launch app lock covers the app: get past it first.
  if (on) await unlock(tester);
  unawaited(container.read(appRouterProvider).push(Routes.appLock));
  await tester.pumpAndSettle();
}

/// Types [pin] on the lock screen (S38).
Future<void> unlock(WidgetTester tester, [String pin = '2580']) async {
  if (find.byType(LockScreen).evaluate().isEmpty) return;
  for (final d in pin.split('')) {
    await tester.tap(
      find.descendant(of: find.byType(LockScreen), matching: find.text(d)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(
      find.descendant(of: find.byType(PinPad), matching: find.text(d)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

ToggleRow toggle(WidgetTester tester, String title) => tester.widget(
  find.byWidgetPredicate((w) => w is ToggleRow && w.title == title),
);

/// Taps S37's toggle row titled [title].
Future<void> tapToggle(WidgetTester tester, String title) async {
  await tester.tap(
    find.byWidgetPredicate((w) => w is ToggleRow && w.title == title),
  );
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  group('S37 App lock', () {
    testWidgets('off: the toggle, biometrics greyed, and the note', (
      tester,
    ) async {
      await pumpAppLock(tester);
      expect(find.text('Ask for your PIN when you open ctrlSpend'), findsOne);
      expect(
        find.text('Face ID or fingerprint, if set up on this phone'),
        findsOneWidget,
      );
      expect(toggle(tester, 'App lock').value, isFalse);
      expect(toggle(tester, 'Unlock with biometrics').onChanged, isNull);
      expect(find.text('OPTIONS'), findsNothing);
      expect(
        find.text(
          'Turning app lock on asks you to create a PIN. If you forget it, '
          "you can reset it with biometrics or your phone's passcode.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('turning it on creates a PIN in two steps', (tester) async {
      await pumpAppLock(tester);
      await tapToggle(tester, 'App lock');
      expect(find.byType(PinFlowScreen), findsOneWidget);
      expect(find.text('STEP 1 OF 2'), findsOneWidget);
      expect(find.text('Create a 4-digit PIN'), findsOneWidget);
      expect(
        find.text(
          "You'll enter it each time you open ctrlSpend. Avoid 1234 or your "
          'birthday.',
        ),
        findsOneWidget,
      );
      await enterPin(tester, '25');
      expect(find.bySemanticsLabel('2 of 4 digits entered'), findsOneWidget);
      await enterPin(tester, '80');
      expect(find.text('STEP 2 OF 2'), findsOneWidget);
      expect(find.text('Enter it again'), findsOneWidget);
      await enterPin(tester, '2580');
      expect(find.byType(AppLockScreen), findsOneWidget);
      expect(pins.pin, '2580');
      expect((await prefs.read()).appLockOn, isTrue);
      expect(find.text('OPTIONS'), findsOneWidget);
    });

    testWidgets('a mismatch turns the dots red and starts again', (
      tester,
    ) async {
      await pumpAppLock(tester);
      await tapToggle(tester, 'App lock');
      await enterPin(tester, '2580');
      await enterPin(tester, '2581');
      expect(
        find.text("Those PINs don't match. Enter your new PIN again."),
        findsOneWidget,
      );
      expect(find.text('STEP 1 OF 2'), findsOneWidget);
      expect(tester.widget<PinDots>(find.byType(PinDots)).error, isTrue);
      expect(pins.pin, isNull);
      await enterPin(tester, '1');
      expect(find.textContaining("don't match"), findsNothing);
    });

    testWidgets('closing the PIN screen leaves it off', (tester) async {
      await pumpAppLock(tester);
      await tapToggle(tester, 'App lock');
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(toggle(tester, 'App lock').value, isFalse);
      expect((await prefs.read()).appLockOn, isFalse);
    });

    testWidgets('turning it off asks for the PIN, then forgets it', (
      tester,
    ) async {
      await pumpAppLock(tester, on: true);
      await tapToggle(tester, 'App lock');
      expect(find.text('Enter your current PIN'), findsOneWidget);
      await enterPin(tester, '1111');
      expect(find.text("That's not your PIN. Try again."), findsOneWidget);
      expect((await prefs.read()).failedPinCount, 1);
      await enterPin(tester, '2580');
      expect(find.byType(AppLockScreen), findsOneWidget);
      expect(pins.pin, isNull);
      final saved = await prefs.read();
      expect((saved.appLockOn, saved.failedPinCount), (false, 0));
    });

    testWidgets('five wrong PINs pause entry for 30 seconds', (tester) async {
      await pumpAppLock(tester, on: true);
      await tapToggle(tester, 'App lock');
      for (var i = 0; i < 5; i++) {
        await enterPin(tester, '1111');
      }
      expect(
        (await prefs.read()).lockoutUntil,
        now.add(const Duration(seconds: 30)),
      );
      expect(
        find.text('Too many wrong PINs. Try again in 0:30.'),
        findsOneWidget,
      );
      expect(tester.widget<PinPad>(find.byType(PinPad)).enabled, isFalse);
      now = now.add(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<PinPad>(find.byType(PinPad)).enabled, isTrue);
    });

    testWidgets('Change PIN asks for the current one, then a new one', (
      tester,
    ) async {
      await pumpAppLock(tester, on: true);
      await tapText(tester, 'Change PIN');
      expect(find.text('Enter your current PIN'), findsOneWidget);
      await enterPin(tester, '2580');
      expect(find.text('Create a 4-digit PIN'), findsOneWidget);
      await enterPin(tester, '1357');
      await enterPin(tester, '1357');
      expect(find.byType(AppLockScreen), findsOneWidget);
      expect(pins.pin, '1357');
    });

    testWidgets('biometrics prompts once before turning on', (tester) async {
      await pumpAppLock(tester, on: true);
      deviceAuth.confirms = false;
      await tapToggle(tester, 'Unlock with biometrics');
      expect(deviceAuth.prompts, hasLength(1));
      expect((await prefs.read()).biometricsOn, isFalse);
      deviceAuth.confirms = true;
      await tapToggle(tester, 'Unlock with biometrics');
      expect((await prefs.read()).biometricsOn, isTrue);
      expect(
        deviceAuth.prompts.last.reason,
        'Confirm to unlock ctrlSpend with biometrics',
      );
    });

    testWidgets('without biometrics on the phone the toggle is off', (
      tester,
    ) async {
      await pumpAppLock(tester, on: true, biometrics: false);
      final row = toggle(tester, 'Unlock with biometrics');
      expect(row.value, isFalse);
      expect(row.onChanged, isNull);
    });

    testWidgets('S68 Lock after saves on Done', (tester) async {
      await pumpAppLock(tester, on: true);
      expect(
        tester
            .widget<ListGroupRow>(
              find.widgetWithText(ListGroupRow, 'Lock after'),
            )
            .value,
        'Immediately',
      );
      await tapText(tester, 'Lock after');
      expect(
        find.text(
          'How long ctrlSpend can stay in the background before it asks '
          'for your PIN again.',
        ),
        findsOneWidget,
      );
      for (final label in [
        'After 1 minute',
        'After 5 minutes',
        'After 15 minutes',
        'After 1 hour',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      await tapText(tester, 'After 5 minutes');
      expect((await prefs.read()).lockAfterMinutes, 0, reason: 'not yet');
      await tapText(tester, 'Done');
      expect((await prefs.read()).lockAfterMinutes, 5);
      expect(find.text('After 5 minutes'), findsOneWidget);
    });

    testWidgets('hiding amounts flags the window and covers the app away', (
      tester,
    ) async {
      await pumpAppLock(tester, on: true);
      expect(secureWindow.hidden, isFalse);
      await tapToggle(tester, 'Hide amounts in app switcher');
      expect((await prefs.read()).hideInSwitcher, isTrue);
      expect(secureWindow.hidden, isTrue);
      Finder cover() => find.descendant(
        of: find.byType(AppSwitcherGuard),
        matching: find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == AppColors.light.ground,
        ),
      );
      final before = cover().evaluate().length;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(cover().evaluate().length, before + 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(cover().evaluate().length, before);
    });

    for (final (theme, colors) in [
      (AppTheme.light, AppColors.light),
      (AppTheme.dark, AppColors.dark),
    ]) {
      testWidgets('uses the theme in ${theme.name} mode', (tester) async {
        await pumpAppLock(tester, on: true, theme: theme);
        expect(
          tester
              .widget<AppToggle>(
                find.descendant(
                  of: find.byWidgetPredicate(
                    (w) => w is ToggleRow && w.title == 'App lock',
                  ),
                  matching: find.byType(AppToggle),
                ),
              )
              .value,
          isTrue,
        );
        expect(
          tester
              .widget<Scaffold>(
                find.descendant(
                  of: find.byType(AppLockScreen),
                  matching: find.byType(Scaffold),
                ),
              )
              .backgroundColor,
          colors.ground,
        );
      });
    }
  });
}
