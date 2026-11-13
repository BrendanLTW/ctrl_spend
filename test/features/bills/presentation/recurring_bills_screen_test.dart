import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/features/bills/domain/bill.dart';
import 'package:ctrl_spend/features/bills/presentation/add_bill_screen.dart';
import 'package:ctrl_spend/features/bills/presentation/bill_row.dart';
import 'package:ctrl_spend/features/bills/presentation/recurring_bills_screen.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_bill_repository.dart';
import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fake_transaction_repository.dart';

/// 4 Nov 2026; with start day 15 the period is 15 Oct – 14 Nov.
final now = DateTime(2026, 11, 4, 9);

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late FakeBillRepository bills;
late ProviderContainer container;

Future<void> pumpApp(
  WidgetTester tester, {
  String location = Routes.bills,
  int? budget = 200000,
  AppTheme theme = AppTheme.system,
  Future<void> Function()? seed = designBills,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  transactions = FakeTransactionRepository();
  categories = FakeCategoryRepository();
  bills = FakeBillRepository(transactions: transactions);
  await seed?.call();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: FakePreferencesRepository(
          Preferences(
            onboardingComplete: true,
            monthStartDay: const DayOfMonth(15),
            monthlyBudgetMinor: budget,
            theme: theme,
          ),
        ),
        categories: categories,
        transactions: transactions,
        bills: bills,
      ),
      clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  // push() completes only when the screen closes, so don't wait for it.
  unawaited(container.read(appRouterProvider).push(location));
  await tester.pumpAndSettle();
}

Future<Bill> addBill(
  String name,
  int amountMinor,
  DateTime due, {
  BillRepeat repeat = const BillRepeat(unit: RepeatUnit.month),
  CategoryIconKey icon = CategoryIconKey.wifi,
  CategoryColorKey colour = CategoryColorKey.blue,
}) => bills.add(
  name: name,
  amountMinor: amountMinor,
  categoryId: categories.byName('Bills').id,
  repeat: repeat.unit == RepeatUnit.month
      ? repeat.copyWith(day: due.day)
      : repeat,
  nextDue: due,
  iconKey: icon,
  colorKey: colour,
);

/// A payment of [bill] on [at], as Mark paid saves it.
Future<void> paid(Bill bill, DateTime at) async {
  final t = await transactions.add(
    amountMinor: bill.amountMinor,
    type: TransactionType.expense,
    categoryId: bill.categoryId,
    occurredAt: at,
    title: bill.name,
  );
  await transactions.update(t.copyWith(billId: bill.id));
}

/// The S27 design: three bills due before 14 Nov (RM 282) and two paid,
/// with RM 760 spent so RM 958 is left after the bills.
Future<void> designBills() async {
  await addBill('Unifi Home Fibre', 12900, DateTime(2026, 11, 8));
  await addBill(
    'Netflix',
    5500,
    DateTime(2026, 11, 12),
    icon: CategoryIconKey.tv,
    colour: CategoryColorKey.pink,
  );
  await addBill(
    'Maxis postpaid',
    9800,
    DateTime(2026, 11, 14),
    icon: CategoryIconKey.phone,
    colour: CategoryColorKey.purple,
  );
  final tnb = await addBill(
    'TNB electricity',
    13900,
    DateTime(2026, 12),
    icon: CategoryIconKey.bolt,
    colour: CategoryColorKey.yellow,
  );
  final spotify = await addBill(
    'Spotify',
    1690,
    DateTime(2026, 11, 20),
    icon: CategoryIconKey.music,
    colour: CategoryColorKey.green,
  );
  await paid(tnb, DateTime(2026, 11, 1, 10));
  await paid(spotify, DateTime(2026, 10, 20, 10));
  await transactions.add(
    amountMinor: 60410,
    type: TransactionType.expense,
    categoryId: categories.byName('Food').id,
    occurredAt: DateTime(2026, 11, 2, 12),
    title: 'Groceries',
  );
}

/// The first row titled [title]: upcoming rows come before paid ones.
BillRow row(WidgetTester tester, String title) => tester
    .widgetList<BillRow>(
      find.byWidgetPredicate((w) => w is BillRow && w.title == title),
    )
    .first;

Future<void> openActions(WidgetTester tester, String title) async {
  await tester.tap(
    find.byWidgetPredicate((w) => w is BillRow && w.title == title).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('S27 Recurring bills', () {
    testWidgets('sums what is due before the period ends', (tester) async {
      await pumpApp(tester);
      expect(find.text('DUE BEFORE 14 NOV'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'RM 282\.00')), findsWidgets);
      expect(
        find.text('3 bills. After these, RM 958 is left to spend.'),
        findsOneWidget,
      );
    });

    testWidgets('a weekly bill due twice before the end counts twice', (
      tester,
    ) async {
      await pumpApp(
        tester,
        seed: () async {
          await designBills();
          await addBill(
            'Gym',
            1000,
            DateTime(2026, 11, 5),
            repeat: const BillRepeat(unit: RepeatUnit.week),
          );
        },
      );
      expect(find.bySemanticsLabel(RegExp(r'RM 302\.00')), findsWidgets);
      expect(
        find.text('5 bills. After these, RM 938 is left to spend.'),
        findsOneWidget,
      );
    });

    testWidgets('without a budget only the count shows', (tester) async {
      await pumpApp(tester, budget: null);
      expect(find.text('3 bills.'), findsOneWidget);
    });

    testWidgets('says how far over budget the bills go', (tester) async {
      await pumpApp(tester, budget: 90000);
      expect(
        find.text("3 bills. After these, you're over budget by RM 142."),
        findsOneWidget,
      );
    });

    testWidgets('lists bills soonest first, coloured by how soon', (
      tester,
    ) async {
      await pumpApp(
        tester,
        seed: () async {
          await designBills();
          await addBill('Water', 1500, DateTime(2026, 11, 2));
          await addBill('Parking', 8000, DateTime(2026, 11, 4));
        },
      );
      const colors = AppColors.light;
      final upcoming = tester
          .widgetList<BillRow>(find.byType(BillRow))
          .where((r) => !r.caption.startsWith('Paid'))
          .toList();
      expect(
        [for (final r in upcoming) r.title],
        [
          'Water',
          'Parking',
          'Unifi Home Fibre',
          'Netflix',
          'Maxis postpaid',
          'Spotify',
          'TNB electricity',
        ],
      );
      expect(row(tester, 'Water').caption, 'Overdue · due 2 Nov');
      expect(row(tester, 'Water').captionColor, colors.negative);
      expect(row(tester, 'Parking').caption, 'Due 4 Nov · today');
      expect(row(tester, 'Unifi Home Fibre').caption, 'Due 8 Nov · in 4 days');
      expect(row(tester, 'Unifi Home Fibre').captionColor, colors.warning);
      expect(row(tester, 'Netflix').caption, 'Due 12 Nov');
      expect(row(tester, 'Netflix').captionColor, colors.muted);
      expect(row(tester, 'Netflix').amount, 'RM 55.00');
    });

    testWidgets("lists this period's payments, which open their detail", (
      tester,
    ) async {
      await pumpApp(tester);
      // The list builds what's on screen; the payments are at the end.
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(find.text('PAID THIS PERIOD'), findsOneWidget);
      final paidRows = tester
          .widgetList<BillRow>(find.byType(BillRow))
          .where((r) => r.caption.startsWith('Paid'))
          .toList();
      expect(
        [for (final r in paidRows) (r.title, r.caption)],
        [('TNB electricity', 'Paid 1 Nov'), ('Spotify', 'Paid 20 Oct')],
      );
      expect(paidRows.first.captionColor, AppColors.light.positive);
      await tester.tap(find.text('Paid 20 Oct'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionDetailScreen), findsOneWidget);
    });

    testWidgets('with no bills shows the empty state, which adds one', (
      tester,
    ) async {
      await pumpApp(tester, seed: null);
      expect(find.text('No bills yet'), findsOneWidget);
      await tester.tap(find.text('Add bill'));
      await tester.pumpAndSettle();
      expect(find.byType(AddBillScreen), findsOneWidget);
    });

    testWidgets('Add opens a new bill', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('New bill'), findsOneWidget);
    });

    testWidgets('Mark paid records the payment and moves the bill on', (
      tester,
    ) async {
      await pumpApp(tester);
      await openActions(tester, 'Unifi Home Fibre');
      expect(find.text('RM 129.00 · Due 8 Nov · in 4 days'), findsOneWidget);
      await tester.tap(find.text('Mark paid'));
      await tester.pumpAndSettle();

      expect(find.text('Unifi Home Fibre marked paid'), findsOneWidget);
      final payment = transactions.all.firstWhere(
        (t) => t.title == 'Unifi Home Fibre',
      );
      expect(payment.billId, isNotNull);
      expect(payment.occurredAt, now.toUtc());
      expect(
        bills.all.firstWhere((b) => b.name == 'Unifi Home Fibre').nextDue,
        DateTime(2026, 12, 8),
      );
      expect(row(tester, 'Unifi Home Fibre').caption, 'Due 8 Dec');
      expect(find.text('Paid 4 Nov'), findsOneWidget);
      // Paid, so it no longer counts as due.
      expect(
        find.text('2 bills. After these, RM 958 is left to spend.'),
        findsOneWidget,
      );
      // Let the toast time out.
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Delete asks first, then keeps past payments', (tester) async {
      await pumpApp(tester);
      await openActions(tester, 'TNB electricity');
      await tester.tap(find.text('Delete bill'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.text('Delete TNB electricity?'), findsOneWidget);
      expect(find.text('Its past payments stay in Activity.'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(bills.all.map((b) => b.name), isNot(contains('TNB electricity')));
      expect(transactions.all.map((t) => t.title), contains('TNB electricity'));
    });

    testWidgets('Edit bill opens it in S28', (tester) async {
      await pumpApp(tester);
      await openActions(tester, 'Netflix');
      await tester.tap(find.text('Edit bill'));
      await tester.pumpAndSettle();
      expect(find.text('Edit bill'), findsOneWidget);
      expect(find.text('Netflix'), findsOneWidget);
    });

    for (final (theme, colors) in [
      (AppTheme.light, AppColors.light),
      (AppTheme.dark, AppColors.dark),
    ]) {
      testWidgets('uses the theme in ${theme.name} mode', (tester) async {
        await pumpApp(tester, theme: theme);
        expect(
          tester
              .widget<Scaffold>(
                find.descendant(
                  of: find.byType(RecurringBillsScreen),
                  matching: find.byType(Scaffold),
                ),
              )
              .backgroundColor,
          colors.ground,
        );
        expect(row(tester, 'Unifi Home Fibre').captionColor, colors.warning);
      });
    }
  });
}
