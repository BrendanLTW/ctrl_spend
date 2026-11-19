import 'dart:async';

import 'package:ctrlspend/core/period/clock.dart';
import 'package:ctrlspend/core/router/app_router.dart';
import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/widgets/app_toggle.dart';
import 'package:ctrlspend/core/widgets/list_group.dart';
import 'package:ctrlspend/core/widgets/message_box.dart';
import 'package:ctrlspend/features/notifications/presentation/notification_service.dart';
import 'package:ctrlspend/features/settings/domain/preferences.dart';
import 'package:ctrlspend/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_notification_scheduler.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';

late FakePreferencesRepository prefs;
late FakeNotificationScheduler scheduler;

/// Opens S48 from Settings. [permitted] is the phone's answer.
Future<void> pumpS48(
  WidgetTester tester, {
  AppTheme theme = AppTheme.system,
  bool permitted = true,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  prefs = FakePreferencesRepository(
    Preferences(userName: 'Alex', onboardingComplete: true, theme: theme),
  );
  scheduler = FakeNotificationScheduler()..permitted = permitted;
  final container = ProviderContainer(
    overrides: [
      ...fakeRepositories(preferences: prefs, scheduler: scheduler),
      clockProvider.overrideWithValue(() => DateTime(2026, 11, 4, 9)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  unawaited(container.read(appRouterProvider).push(Routes.settings));
  await tester.pumpAndSettle();
  unawaited(
    container.read(appRouterProvider).push(Routes.notificationSettings),
  );
  await tester.pumpAndSettle();
}

bool toggle(WidgetTester tester, String title) => tester
    .widget<AppToggle>(
      find.descendant(
        of: find.ancestor(of: find.text(title), matching: find.byType(InkWell)),
        matching: find.byType(AppToggle),
      ),
    )
    .value;

void main() {
  testWidgets('the rows, their copy and saved values', (tester) async {
    await pumpS48(tester);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.byType(MessageBox), findsNothing, reason: 'permitted');
    expect(find.text('REMINDERS'), findsOneWidget);
    expect(find.text("A nudge to log today's spending"), findsOneWidget);
    expect(
      tester
          .widget<ListGroupRow>(
            find.widgetWithText(ListGroupRow, 'Remind me at'),
          )
          .value,
      // intl puts a narrow no-break space before PM.
      '9:00\u202fPM',
    );
    expect(find.text('ALERTS AND SUMMARIES'), findsOneWidget);
    expect(find.text("Before each bill's due date"), findsOneWidget);
    expect(
      find.text(
        'Each alert fires once per period. Notifications are created on '
        'this phone and nothing is sent to a server.',
      ),
      findsOneWidget,
    );
    expect(toggle(tester, 'Daily reminder'), isTrue);
    expect(toggle(tester, 'Weekly summary'), isFalse);
    expect(toggle(tester, 'Bill reminders'), isTrue);
  });

  testWidgets('toggles save straight away and reschedule', (tester) async {
    await pumpS48(tester);
    await tester.tap(find.text('Weekly summary'));
    await tester.pumpAndSettle();
    expect((await prefs.read()).weeklySummaryOn, isTrue);
    expect(scheduler.pending[NotificationService.weeklyId]?.kind, 'weekly');
    await tester.tap(find.text('Bill reminders'));
    await tester.pumpAndSettle();
    expect((await prefs.read()).billRemindersOn, isFalse);
    await tester.tap(find.text('Daily reminder'));
    await tester.pumpAndSettle();
    expect(scheduler.pending[NotificationService.dailyId], isNull);
  });

  testWidgets('Remind me at picks a time on a wheel', (tester) async {
    await pumpS48(tester);
    await tester.tap(find.text('Remind me at'));
    await tester.pumpAndSettle();
    final wheel = tester.widget<CupertinoDatePicker>(
      find.byType(CupertinoDatePicker),
    );
    expect(wheel.initialDateTime, DateTime(2000, 1, 1, 21));
    wheel.onDateTimeChanged(DateTime(2000, 1, 1, 20, 30));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await prefs.read()).dailyReminderMinutes, 20 * 60 + 30);
    expect(find.text('8:30\u202fPM'), findsOneWidget);
    expect(scheduler.pending[NotificationService.dailyId]?.minutes, 1230);
  });

  testWidgets('closing the wheel keeps the time', (tester) async {
    await pumpS48(tester);
    await tester.tap(find.text('Remind me at'));
    await tester.pumpAndSettle();
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(2000, 1, 1, 7));
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect((await prefs.read()).dailyReminderMinutes, 21 * 60);
  });

  testWidgets('permission off: the banner opens the phone settings and '
      'goes once allowed', (tester) async {
    await pumpS48(tester, permitted: false);
    expect(find.text('Notifications are off for ctrlSpend'), findsOneWidget);
    expect(
      find.text(
        "You said no when we asked. Turn them on in your phone's Settings "
        'to get these reminders.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Open phone settings'));
    expect(scheduler.settingsOpened, 1);

    // The toggles still save.
    await tester.tap(find.text('Weekly summary'));
    await tester.pumpAndSettle();
    expect((await prefs.read()).weeklySummaryOn, isTrue);

    scheduler.permitted = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(MessageBox), findsNothing);
  });

  testWidgets('the banner link is its own button for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpS48(tester, permitted: false);
    expect(
      tester.getSemantics(find.text('Open phone settings')),
      isSemantics(
        label: 'Open phone settings',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('the banner is amber in ${theme.name} mode', (tester) async {
      await pumpS48(tester, theme: theme, permitted: false);
      expect(
        tester.widget<MessageBox>(find.byType(MessageBox)).kind,
        MessageKind.warning,
      );
      expect(
        tester
            .widget<Text>(find.text('Notifications are off for ctrlSpend'))
            .style!
            .color,
        colors.onWarningBox,
      );
    });
  }
}
