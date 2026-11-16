import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/bills/presentation/add_bill_screen.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_detail_screen.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_row.dart';
import 'package:ctrl_spend/features/bills/presentation/recurring_bills_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recurring_bills_screen_test.dart' as rb;

/// Unifi (due 8 Nov, paid on 8 Sep and 8 Oct) and the S27 design.
Future<void> unifiHistory() async {
  await rb.designBills();
  final unifi = rb.bills.all.firstWhere((b) => b.name == 'Unifi Home Fibre');
  await rb.paid(unifi, DateTime(2026, 9, 9, 10));
  await rb.paid(unifi, DateTime(2026, 10, 8, 10));
}

/// Opens S56 for [name] from S27.
Future<void> pumpDetail(
  WidgetTester tester, {
  String name = 'Unifi Home Fibre',
  AppTheme theme = AppTheme.system,
}) async {
  await rb.pumpApp(tester, theme: theme, seed: unifiHistory);
  await tester.tap(find.text(name).first);
  await tester.pumpAndSettle();
}

String kv(WidgetTester tester, String label) =>
    tester.widget<KeyValueRow>(find.widgetWithText(KeyValueRow, label)).value;

void main() {
  testWidgets('shows the bill, its settings and its payments', (tester) async {
    await pumpDetail(tester);
    expect(find.byType(BillDetailScreen), findsOneWidget);
    expect(find.text('Bill'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Unifi Home Fibre, Every month on the 8th, RM 129.00, '
        'Due 8 Nov · in 4 days',
      ),
      findsOneWidget,
    );
    expect(kv(tester, 'Category'), 'Bills');
    expect(kv(tester, 'Reminder'), 'Off');
    expect(tester.widget<AppToggle>(find.byType(AppToggle)).value, isFalse);
    expect(find.text('HISTORY'), findsOneWidget);
    final history = tester.widgetList<BillRow>(find.byType(BillRow)).toList();
    expect(
      [for (final r in history) (r.title, r.caption, r.amount)],
      [
        ('Paid 8 Oct', 'Added to Bills', 'RM 129.00'),
        ('Paid 9 Sep', 'Added to Bills', 'RM 129.00'),
      ],
    );
    expect(find.text('Mark as paid'), findsOneWidget);
    expect(find.text('Delete bill'), findsOneWidget);
  });

  testWidgets('a reminder reads as days before', (tester) async {
    await pumpDetail(tester);
    final unifi = rb.bills.all.firstWhere((b) => b.name == 'Unifi Home Fibre');
    await rb.bills.update(unifi.copyWith(remindDaysBefore: 2));
    await tester.pumpAndSettle();
    expect(kv(tester, 'Reminder'), '2 days before');
  });

  testWidgets('no payments yet: no History', (tester) async {
    await pumpDetail(tester, name: 'Netflix');
    expect(find.text('HISTORY'), findsNothing);
  });

  testWidgets('Pause this bill saves straight away', (tester) async {
    await pumpDetail(tester);
    await tester.tap(find.text('Pause this bill'));
    await tester.pumpAndSettle();
    expect(
      rb.bills.all.firstWhere((b) => b.name == 'Unifi Home Fibre').paused,
      isTrue,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Unifi Home Fibre, .*, Paused$')),
      findsOneWidget,
    );
  });

  testWidgets('Mark as paid opens S57', (tester) async {
    await pumpDetail(tester);
    await tester.tap(find.text('Mark as paid'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Unifi Home Fibre'), findsWidgets);
  });

  testWidgets('Edit opens S28', (tester) async {
    await pumpDetail(tester);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.byType(AddBillScreen), findsOneWidget);
    expect(find.text('Edit bill'), findsOneWidget);
  });

  testWidgets('Delete asks first, then keeps past payments', (tester) async {
    await pumpDetail(tester);
    await tester.tap(find.text('Delete bill'));
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsOneWidget);
    expect(find.text('Delete Unifi Home Fibre?'), findsOneWidget);
    expect(find.text('Its past payments stay in Activity.'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(RecurringBillsScreen), findsOneWidget);
    expect(
      rb.bills.all.map((b) => b.name),
      isNot(contains('Unifi Home Fibre')),
    );
    expect(
      rb.transactions.all.where((t) => t.title == 'Unifi Home Fibre'),
      hasLength(2),
    );
  });

  testWidgets('an overdue bill says when it was due', (tester) async {
    await rb.pumpApp(
      tester,
      seed: () => rb.addBill('Water', 1500, DateTime(2026, 11, 2)),
    );
    await tester.tap(find.text('Water'));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp(r'Overdue · was due 2 Nov$')),
      findsOneWidget,
    );
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('the card is the hero in ${theme.name} mode', (tester) async {
      await pumpDetail(tester, theme: theme);
      final colors = theme == AppTheme.light ? AppColors.light : AppColors.dark;
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(BillDetailScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
    });
  }

  test('the route builds S56', () {
    expect(Routes.bill(3), '/settings/bills/3');
  });
}
