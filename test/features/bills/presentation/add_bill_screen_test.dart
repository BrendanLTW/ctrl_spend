import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/detail_rows.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/presentation/add_bill_screen.dart';
import 'package:ctrl_spend/features/bills/presentation/recurring_bills_screen.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../transactions/presentation/add_transaction_screen_test.dart'
    show done, type;
import 'recurring_bills_screen_test.dart' as rb;

/// Opens S28 from S27 with no bills, so Save returns to S27.
Future<void> openNewBill(
  WidgetTester tester, {
  AppTheme theme = AppTheme.system,
}) async {
  await rb.pumpApp(tester, seed: null, theme: theme);
  await tester.tap(find.text('Add bill'));
  await tester.pumpAndSettle();
}

/// Types the amount on the keypad S28 opens with, and a name.
Future<void> fillIn(WidgetTester tester, {String name = 'Unifi'}) async {
  await type(tester, '12900');
  await done(tester);
  await tester.enterText(find.byType(TextField), name);
  await tester.pump();
}

DetailRow detail(WidgetTester tester, String label) => tester.widget<DetailRow>(
  find.byWidgetPredicate((w) => w is DetailRow && w.label == label),
);

Future<void> tapDetail(WidgetTester tester, String label) async {
  await tester.tap(
    find.byWidgetPredicate((w) => w is DetailRow && w.label == label),
  );
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(PrimaryButton, 'Save bill'));
  await tester.pumpAndSettle();
}

PrimaryButton saveButton(WidgetTester tester) =>
    tester.widget(find.widgetWithText(PrimaryButton, 'Save bill'));

void main() {
  group('S28 New bill', () {
    testWidgets('opens the keypad, defaults to Bills, monthly, today', (
      tester,
    ) async {
      await openNewBill(tester);
      expect(find.text('New bill'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget, reason: 'keypad sheet');
      await done(tester);
      expect(find.text('AMOUNT EACH TIME'), findsOneWidget);
      expect(detail(tester, 'Category').value, 'Bills');
      expect(detail(tester, 'Repeats').value, 'Every month');
      expect(detail(tester, 'Next due').value, '4 Nov 2026');
      expect(find.text("2 days before it's due"), findsOneWidget);
    });

    testWidgets('Save needs an amount and a name', (tester) async {
      await openNewBill(tester);
      await type(tester, '12900');
      await done(tester);
      expect(saveButton(tester).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(saveButton(tester).onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'Unifi');
      await tester.pump();
      expect(saveButton(tester).onPressed, isNotNull);
    });

    testWidgets('saves a monthly bill on its due day, with a reminder', (
      tester,
    ) async {
      await openNewBill(tester);
      await fillIn(tester, name: ' Unifi Home Fibre ');
      await tapDetail(tester, 'Next due');
      await tester.tap(find.bySemanticsLabel('Sunday, November 8, 2026'));
      await tester.pump();
      await tester.tap(find.text('Set 8 Nov'));
      await tester.pumpAndSettle();
      // Above the fixed Save button, not behind it.
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Wi-Fi'));
      await tester.tap(find.bySemanticsLabel('Blue'));
      await tester.pump();
      await save(tester);

      expect(find.byType(RecurringBillsScreen), findsOneWidget);
      final bill = rb.bills.all.single;
      expect(bill.name, 'Unifi Home Fibre');
      expect(bill.amountMinor, 12900);
      expect(bill.categoryId, rb.categories.byName('Bills').id);
      expect(bill.repeat, const BillRepeat(unit: RepeatUnit.month, day: 8));
      expect(bill.nextDue, DateTime(2026, 11, 8));
      expect(bill.remindDaysBefore, AddBillScreen.remindDays);
      expect(
        (bill.iconKey, bill.colorKey),
        (CategoryIconKey.wifi, CategoryColorKey.blue),
      );
    });

    testWidgets('Remind me off saves no reminder', (tester) async {
      await openNewBill(tester);
      await fillIn(tester);
      await tester.tap(find.text('Remind me'));
      await tester.pump();
      await save(tester);
      expect(rb.bills.all.single.remindDaysBefore, isNull);
    });

    testWidgets('the category comes from the expense categories', (
      tester,
    ) async {
      await openNewBill(tester);
      await fillIn(tester);
      await tapDetail(tester, 'Category');
      expect(find.text('Salary'), findsNothing);
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();
      expect(detail(tester, 'Category').value, 'Health');
      await save(tester);
      expect(rb.bills.all.single.categoryId, rb.categories.byName('Health').id);
    });

    testWidgets('S44 picks a preset; weeks keep no day', (tester) async {
      await openNewBill(tester);
      await fillIn(tester);
      await tapDetail(tester, 'Repeats');
      expect(find.text('On the 4th'), findsOneWidget);
      await tester.tap(find.text('Every 2 weeks'));
      await tester.pumpAndSettle();
      expect(detail(tester, 'Repeats').value, 'Every 2 weeks');
      await save(tester);
      expect(
        rb.bills.all.single.repeat,
        const BillRepeat(unit: RepeatUnit.week, every: 2),
      );
    });

    testWidgets('Custom… sets any count of days, weeks, months or years', (
      tester,
    ) async {
      await openNewBill(tester);
      await fillIn(tester);
      await tapDetail(tester, 'Repeats');
      await tester.tap(find.text('Custom…'));
      await tester.pumpAndSettle();
      expect(find.text('Custom repeat'), findsOneWidget);
      expect(find.byTooltip('Fewer'), findsOneWidget);
      for (var i = 0; i < 9; i++) {
        await tester.tap(find.byTooltip('More'));
        await tester.pump();
      }
      await tester.tap(find.text('Days'));
      await tester.pump();
      expect(find.text('Every 10 days'), findsOneWidget);
      await tester.tap(find.text('Set'));
      await tester.pumpAndSettle();
      expect(detail(tester, 'Repeats').value, 'Every 10 days');

      // S44 now shows it under Custom….
      await tapDetail(tester, 'Repeats');
      expect(find.text('Every 10 days'), findsWidgets);
      await tester.tapAt(const Offset(195, 100));
      await tester.pumpAndSettle();

      await save(tester);
      expect(
        rb.bills.all.single.repeat,
        const BillRepeat(unit: RepeatUnit.day, every: 10),
      );
    });

    testWidgets('Custom… goes no lower than 1', (tester) async {
      await openNewBill(tester);
      await fillIn(tester);
      await tapDetail(tester, 'Repeats');
      await tester.tap(find.text('Custom…'));
      await tester.pumpAndSettle();
      IconButton button(String tooltip) => tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(tooltip),
          matching: find.byType(IconButton),
        ),
      );
      expect(button('Fewer').onPressed, isNull);
      expect(button('More').onPressed, isNotNull);
    });
  });

  group('S28 Edit bill', () {
    testWidgets('fills in the bill and saves changes', (tester) async {
      await rb.pumpApp(tester);
      await rb.openActions(tester, 'Netflix');
      await tester.tap(find.text('Edit bill'));
      await tester.pumpAndSettle();
      expect(find.text('Edit bill'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Amount each time, RM 55.00')),
        findsOneWidget,
      );
      expect(detail(tester, 'Next due').value, '12 Nov 2026');
      await tester.enterText(find.byType(TextField), 'Netflix Premium');
      await tester.pump();
      await save(tester);
      final bill = rb.bills.all.firstWhere((b) => b.amountMinor == 5500);
      expect(bill.name, 'Netflix Premium');
      expect(bill.iconKey, CategoryIconKey.tv);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('S28 uses the theme in ${theme.name} mode', (tester) async {
      await openNewBill(tester, theme: theme);
      await done(tester);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(AddBillScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
    });
  }
}
