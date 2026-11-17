import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/features/app_lock/presentation/forgot_pin_screen.dart';
import 'package:ctrl_spend/features/app_lock/presentation/lock_screen.dart';
import 'package:ctrl_spend/features/app_lock/presentation/pin_flow_screen.dart';
import 'package:ctrl_spend/features/app_lock/presentation/pin_pad.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_lock.dart';
import '../../../helpers/fake_data_eraser.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';

late FakePreferencesRepository prefs;
late FakePinStore pins;
late FakeDeviceAuth deviceAuth;
late ProviderContainer container;
DateTime now = DateTime(2026, 11, 4, 9);

/// Launches the app with app lock on and the PIN 2580.
Future<void> pumpLocked(
  WidgetTester tester, {
  AppTheme theme = AppTheme.system,
  bool lockOn = true,
  String? pin = '2580',
  bool biometricsOn = false,
  bool confirms = false,
  bool secure = true,
  int lockAfterMinutes = 0,
  DateTime? lockoutUntil,
  String name = 'Alex',
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  now = DateTime(2026, 11, 4, 9);
  prefs = FakePreferencesRepository(
    Preferences(
      userName: name,
      onboardingComplete: true,
      theme: theme,
      appLockOn: lockOn,
      biometricsOn: biometricsOn,
      lockAfterMinutes: lockAfterMinutes,
      lockoutUntil: lockoutUntil,
      failedPinCount: lockoutUntil == null ? 0 : 5,
    ),
  );
  pins = FakePinStore(pin);
  deviceAuth = FakeDeviceAuth(confirms: confirms, secure: secure);
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: prefs,
        pin: pins,
        deviceAuth: deviceAuth,
        eraser: FakeDataEraser(preferences: prefs),
      ),
      clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
}

Future<void> typePin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(
      find.descendant(of: find.byType(LockScreen), matching: find.text(d)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

/// The app goes to the background and comes back [later].
Future<void> leaveAndReturn(WidgetTester tester, Duration later) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  now = now.add(later);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
}

bool locked() => find.byType(LockScreen).evaluate().isNotEmpty;

void main() {
  group('S38 Lock screen', () {
    testWidgets('locks at launch; the right PIN opens Home', (tester) async {
      await pumpLocked(tester);
      expect(locked(), isTrue);
      expect(find.text('Welcome back, Alex'), findsOneWidget);
      expect(find.text('Enter your PIN'), findsOneWidget);
      expect(find.text('Forgot PIN?'), findsOneWidget);
      expect(find.bySemanticsLabel('Unlock with biometrics'), findsNothing);
      await typePin(tester, '25');
      expect(find.bySemanticsLabel('2 of 4 digits entered'), findsOneWidget);
      await typePin(tester, '80');
      expect(locked(), isFalse);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('without a name it just says Welcome back', (tester) async {
      await pumpLocked(tester, name: '');
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('a wrong PIN counts and clears', (tester) async {
      await pumpLocked(tester);
      await typePin(tester, '1111');
      expect(locked(), isTrue);
      expect((await prefs.read()).failedPinCount, 1);
      await typePin(tester, '2580');
      expect(locked(), isFalse);
      expect((await prefs.read()).failedPinCount, 0);
    });

    testWidgets('no lock when it is off', (tester) async {
      await pumpLocked(tester, lockOn: false);
      expect(locked(), isFalse);
    });

    testWidgets('no lock without a saved PIN', (tester) async {
      await pumpLocked(tester, pin: null);
      expect(locked(), isFalse);
    });

    testWidgets('biometrics prompt at launch and from the key', (tester) async {
      await pumpLocked(tester, biometricsOn: true);
      expect(deviceAuth.prompts.single.reason, 'Unlock ctrlSpend');
      expect(locked(), isTrue, reason: 'cancelled');
      deviceAuth.confirms = true;
      await tester.tap(find.bySemanticsLabel('Unlock with biometrics'));
      await tester.pumpAndSettle();
      expect(locked(), isFalse);
    });

    testWidgets('Back while locked stays on the lock screen', (tester) async {
      await pumpLocked(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(locked(), isTrue);
    });
  });

  group('locking on return', () {
    testWidgets('Immediately: any trip to the background', (tester) async {
      await pumpLocked(tester);
      await typePin(tester, '2580');
      await leaveAndReturn(tester, Duration.zero);
      expect(locked(), isTrue);
    });

    testWidgets('after the Lock after time, not before', (tester) async {
      await pumpLocked(tester, lockAfterMinutes: 5);
      await typePin(tester, '2580');
      await leaveAndReturn(tester, const Duration(minutes: 4));
      expect(locked(), isFalse);
      await leaveAndReturn(tester, const Duration(minutes: 5));
      expect(locked(), isTrue);
    });

    testWidgets('a prompt or banner (inactive only) does not lock', (
      tester,
    ) async {
      await pumpLocked(tester);
      await typePin(tester, '2580');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(locked(), isFalse);
    });

    testWidgets('the screen underneath is kept', (tester) async {
      await pumpLocked(tester);
      await typePin(tester, '2580');
      unawaited(container.read(appRouterProvider).push(Routes.settings));
      await tester.pumpAndSettle();
      await leaveAndReturn(tester, Duration.zero);
      await typePin(tester, '2580');
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('S66 Too many attempts', () {
    testWidgets('five wrong PINs pause the keypad, not biometrics', (
      tester,
    ) async {
      await pumpLocked(tester, biometricsOn: true);
      for (var i = 0; i < 5; i++) {
        await typePin(tester, '1111');
      }
      expect(find.text('Too many wrong PINs'), findsOneWidget);
      expect(find.text('Try again in 0:30, or use biometrics'), findsOneWidget);
      expect(find.bySemanticsLabel('PIN entry paused'), findsOneWidget);
      await typePin(tester, '2580');
      expect(locked(), isTrue, reason: 'the keypad is paused');
      deviceAuth.confirms = true;
      await tester.tap(find.bySemanticsLabel('Unlock with biometrics'));
      await tester.pumpAndSettle();
      expect(locked(), isFalse);
      expect((await prefs.read()).failedPinCount, 0);
    });

    testWidgets('the pause survives a restart, then lifts', (tester) async {
      await pumpLocked(tester, lockoutUntil: DateTime(2026, 11, 4, 9, 0, 28));
      expect(find.text('Try again in 0:28'), findsOneWidget);
      now = now.add(const Duration(seconds: 29));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Enter your PIN'), findsOneWidget);
      await typePin(tester, '2580');
      expect(locked(), isFalse);
    });
  });

  group('S67 Forgot PIN', () {
    testWidgets('biometrics, then a new PIN, and back in', (tester) async {
      await pumpLocked(tester, confirms: true);
      await tapText(tester, 'Forgot PIN?');
      expect(find.byType(ForgotPinScreen), findsOneWidget);
      expect(find.text('Reset PIN'), findsOneWidget);
      expect(find.text('Forgot your PIN?'), findsOneWidget);
      expect(
        find.text(
          'If neither is set up on this phone, the only way back in is to '
          "erase ctrlSpend's data on the next screen.",
        ),
        findsOneWidget,
      );
      await tapText(tester, 'Continue with biometrics');
      expect(deviceAuth.prompts.last.biometricOnly, isTrue);
      expect(find.byType(PinFlowScreen), findsOneWidget);
      for (final pin in ['1357', '1357']) {
        for (final d in pin.split('')) {
          await tester.tap(
            find.descendant(of: find.byType(PinPad), matching: find.text(d)),
          );
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }
      expect(locked(), isFalse);
      expect(pins.pin, '1357');
    });

    testWidgets('the phone passcode works too; Back returns to S38', (
      tester,
    ) async {
      await pumpLocked(tester);
      await tapText(tester, 'Forgot PIN?');
      await tapText(tester, 'Use phone passcode');
      expect(deviceAuth.prompts.last.biometricOnly, isFalse);
      expect(find.byType(PinFlowScreen), findsNothing, reason: 'cancelled');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPinScreen), findsNothing);
      expect(locked(), isTrue);
    });

    testWidgets('with no phone lock, only erasing gets back in', (
      tester,
    ) async {
      await pumpLocked(tester, secure: false);
      await tapText(tester, 'Forgot PIN?');
      await tapText(tester, 'Continue with biometrics');
      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.text('Export a CSV first'), findsNothing);
      await tapText(tester, 'Erase everything');
      expect(locked(), isFalse);
      expect(pins.pin, isNull);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });
  });

  group('Preview from S37', () {
    testWidgets('closes, has no Forgot PIN, and counts no wrong PINs', (
      tester,
    ) async {
      await pumpLocked(tester);
      await typePin(tester, '2580');
      unawaited(container.read(appRouterProvider).push(Routes.lockPreview));
      await tester.pumpAndSettle();
      expect(find.text('Forgot PIN?'), findsNothing);
      await typePin(tester, '1111');
      expect((await prefs.read()).failedPinCount, 0);
      await typePin(tester, '2580');
      expect(locked(), isFalse);
      unawaited(container.read(appRouterProvider).push(Routes.lockPreview));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(locked(), isFalse);
    });
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('the lock screen is the hero colour in ${theme.name}', (
      tester,
    ) async {
      await pumpLocked(tester, theme: theme);
      final colors = theme == AppTheme.light ? AppColors.light : AppColors.dark;
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(LockScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.hero,
      );
    });
  }
}
