import 'package:ctrl_spend/core/db/app_database.dart'
    show AppDatabase, appDatabaseProvider;
import 'package:ctrl_spend/core/widgets/app_shell_tab.dart';
import 'package:ctrl_spend/core/widgets/category_picker_tile.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/swipe_to_delete.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/activity/presentation/activity_screen.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrl_spend/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/fake_notification_scheduler.dart';

/// The one end-to-end test (PRD §10): onboarding → add an expense → the
/// dashboard reflects it → delete it → Undo brings it back. The real app
/// and Drift, on a fresh in-memory database. Run on a device or
/// simulator: `flutter test integration_test/app_flow_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> keypad(WidgetTester tester, String keys) async {
    for (final key in keys.split('')) {
      await tester.tap(find.widgetWithText(InkWell, key).last);
      await tester.pump();
    }
  }

  Finder amount(String text) => find.text(text, findRichText: true);

  /// Only the active tab shows its label, so find tabs by widget.
  Finder tab(String label) =>
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == label);

  testWidgets('onboard, add an expense, delete it and undo', (tester) async {
    final container = ProviderContainer(
      overrides: [
        // No OS notifications from a test run.
        ...appOverrides(scheduler: FakeNotificationScheduler()),
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.pumpAndSettle();

    // Onboarding, S02 to S08.
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await tapText(tester, 'Get started');
    await tapText(tester, 'Continue');
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pump();
    await tapText(tester, 'Continue');
    await tapText(tester, 'Continue');
    // The keypad enters cents: RM 2,000.00.
    await keypad(tester, '200000');
    await tapText(tester, 'Continue');
    await tapText(tester, 'Skip');
    await tapText(tester, 'Not now');
    await tapText(tester, 'Go to dashboard');

    // The dashboard, with the budget and nothing spent.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Hi, Alex'), findsOneWidget);
    expect(amount('RM 2,000.00'), findsOneWidget);

    // Add an expense: S12.
    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();
    await keypad(tester, '1250');
    await tapText(tester, 'Done');
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is CategoryPickerTile && w.label == 'Food',
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nasi lemak');
    await tester.pump();
    await tester.tap(find.widgetWithText(PrimaryButton, 'Save'));
    await tester.pumpAndSettle();

    // The dashboard reflects it.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(amount('RM 1,987.50'), findsOneWidget);
    expect(find.widgetWithText(TransactionRow, 'Nasi lemak'), findsOneWidget);

    // Delete it in Activity, then Undo.
    await tester.tap(tab('Activity'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityScreen), findsOneWidget);
    await tester.drag(
      find.widgetWithText(TransactionRow, 'Nasi lemak'),
      const Offset(-150, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(SwipeToDelete),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TransactionRow, 'Nasi lemak'), findsNothing);
    expect(find.text('Transaction deleted'), findsOneWidget);
    await tapText(tester, 'Undo');
    expect(find.widgetWithText(TransactionRow, 'Nasi lemak'), findsOneWidget);

    // Back on the dashboard it counts again.
    await tester.tap(tab('Home'));
    await tester.pumpAndSettle();
    expect(amount('RM 1,987.50'), findsOneWidget);
  });
}
