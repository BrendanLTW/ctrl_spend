import 'dart:async';

import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_row.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_service.dart';
import 'package:ctrl_spend/features/notifications/presentation/notifications_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'notification_service_test.dart'
    show categories, container, inbox, onboarded, prefs, pumpApp, scheduler;

/// The design's inbox, with "now" at 4 Nov 2026, 9:00.
Future<void> designInbox() async {
  Future<void> add(
    NotificationKind kind,
    String title,
    String body,
    DateTime at, {
    String? category,
  }) => inbox.add(
    kind: kind,
    title: title,
    body: body,
    createdAt: at,
    categoryId: category == null ? null : categories.byName(category).id,
  );

  await add(
    NotificationKind.periodStarted,
    'New period started',
    '15 Oct – 14 Nov. Your RM 2,000 budget has reset.',
    DateTime(2026, 10, 15, 9),
  );
  await add(
    NotificationKind.incomeRecorded,
    'Salary added',
    '+RM 4,800.00 recorded as Income.',
    DateTime(2026, 11, 2, 10),
    category: 'Salary',
  );
  await add(
    NotificationKind.dailyReminder,
    'Daily reminder',
    'Anything to log from today? It takes ten seconds.',
    DateTime(2026, 11, 3, 21),
  );
  await add(
    NotificationKind.overBudget,
    'Shopping is over budget',
    "You've spent RM 210 of your RM 200 limit.",
    DateTime(2026, 11, 4, 4),
    category: 'Shopping',
  );
  await add(
    NotificationKind.budgetWarning,
    'Food is at 82% of its limit',
    'RM 72 left with 10 days to go.',
    DateTime(2026, 11, 4, 7),
    category: 'Food',
  );
  // Read before.
  await inbox.markAllRead(DateTime(2026, 11, 3, 22));
}

Future<void> openInbox(WidgetTester tester) async {
  unawaited(container.read(appRouterProvider).push(Routes.notifications));
  await tester.pumpAndSettle();
}

List<NotificationRow> rows(WidgetTester tester) =>
    tester.widgetList<NotificationRow>(find.byType(NotificationRow)).toList();

/// Two new alerts on top of the read history.
Future<void> seedWithUnread() async {
  await designInbox();
  for (final (i, n) in inbox.all.indexed) {
    if (n.createdAt.isAfter(DateTime(2026, 11, 4))) {
      inbox.all[i] = n.copyWith(readAt: null);
    }
  }
}

void main() {
  group('S14 Notifications', () {
    testWidgets('groups Today and Earlier with time labels', (tester) async {
      await pumpApp(tester, seed: seedWithUnread);
      await openInbox(tester);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('EARLIER'), findsOneWidget);
      expect(
        [for (final r in rows(tester)) r.notification.title],
        [
          'Food is at 82% of its limit',
          'Shopping is over budget',
          'Daily reminder',
          'Salary added',
          'New period started',
        ],
      );
      expect(
        [for (final r in rows(tester)) r.time],
        ['2h', '5h', 'Yesterday', '2 Nov', '15 Oct'],
      );
    });

    testWidgets('alerts use their category tile, others their kind', (
      tester,
    ) async {
      await pumpApp(tester, seed: seedWithUnread);
      await openInbox(tester);
      CategoryTile tile(int i) => tester.widget<CategoryTile>(
        find.descendant(
          of: find.byWidget(rows(tester)[i]),
          matching: find.byType(CategoryTile),
        ),
      );
      expect(tile(0).icon, categoryIcon(CategoryIconKey.food));
      expect(tile(0).color, CategoryColorKey.orange);
      expect(tile(2).icon, Icons.notifications_none_rounded);
      expect(tile(2).color, CategoryColorKey.purple);
    });

    testWidgets('opening marks all read; dots stay for this visit', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, seed: seedWithUnread);
      expect(find.bySemanticsLabel('Notifications, 2 unread'), findsOneWidget);
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(
        [for (final r in rows(tester)) r.unread],
        [true, true, false, false, false],
      );
      expect(
        find.bySemanticsLabel(RegExp('^Unread, Food is at 82%')),
        findsOneWidget,
      );
      expect(inbox.all.every((n) => n.readAt != null), isTrue);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the settings icon opens the toggles', (tester) async {
      await pumpApp(tester, seed: seedWithUnread);
      await openInbox(tester);
      await tester.tap(find.byTooltip('Notification settings'));
      await tester.pumpAndSettle();
      expect(find.byType(AppToggle), findsNWidgets(3));
      await tester.tap(find.text('Weekly summary'));
      await tester.pumpAndSettle();
      expect((await prefs.read()).weeklySummaryOn, isTrue);
      expect(scheduler.pending[NotificationService.weeklyId]?.kind, 'weekly');
    });
  });

  group('S15 empty', () {
    testWidgets('shows the copy and which kinds are on', (tester) async {
      await pumpApp(tester);
      await openInbox(tester);
      expect(find.text('No notifications yet'), findsOneWidget);
      expect(
        find.text(
          "We'll let you know when a budget gets close to its limit, and "
          'remind you to log your spending.',
        ),
        findsOneWidget,
      );
      expect(find.text("YOU'LL HEAR ABOUT"), findsOneWidget);
      final shown = {
        for (final r in tester.widgetList<ListGroupRow>(
          find.byType(ListGroupRow),
        ))
          r.title: (r.subtitle, r.value),
      };
      expect(shown, {
        'Budget alerts': ('At 80% and 100%', 'On'),
        'Daily reminder': ('Every day at 9:00 PM', 'On'),
        'Weekly summary': ('Sunday evenings', 'Off'),
      });
    });

    testWidgets('a row opens the toggles', (tester) async {
      await pumpApp(tester);
      await openInbox(tester);
      await tester.tap(find.text('Budget alerts'));
      await tester.pumpAndSettle();
      expect(find.text('Notification settings'), findsOneWidget);
      await tester.tap(find.text('When a budget reaches 80% and 100%'));
      await tester.pumpAndSettle();
      expect((await prefs.read()).budgetAlertsOn, isFalse);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpApp(
        tester,
        initial: onboarded.copyWith(theme: theme),
        seed: seedWithUnread,
      );
      await openInbox(tester);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(NotificationsScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(NotificationRow).first,
              matching: find.byType(Container),
            )
            .first,
      );
      expect((card.decoration! as BoxDecoration).color, colors.surface);
    });
  }
}
