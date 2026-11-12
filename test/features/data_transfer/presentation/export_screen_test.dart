import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/export_screen.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_file_sharer.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fake_transaction_repository.dart';

/// 4 Nov 2026; with start day 15 the period is 15 Oct – 14 Nov.
final now = DateTime(2026, 11, 4, 9);

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late FakeFileSharer sharer;
late ProviderContainer container;

Future<void> pumpExport(
  WidgetTester tester, {
  AppTheme theme = AppTheme.system,
  bool shares = true,
  Future<void> Function()? seed = history,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  transactions = FakeTransactionRepository();
  categories = FakeCategoryRepository();
  sharer = FakeFileSharer(shares: shares);
  await seed?.call();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: FakePreferencesRepository(
          Preferences(
            onboardingComplete: true,
            monthStartDay: const DayOfMonth(15),
            theme: theme,
          ),
        ),
        categories: categories,
        transactions: transactions,
        sharer: sharer,
      ),
      clockProvider.overrideWithValue(() => now),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
  await tester.pumpAndSettle();
  unawaited(container.read(appRouterProvider).push(Routes.export));
  await tester.pumpAndSettle();
}

Future<void> add(
  int minor,
  String category,
  DateTime at,
  String title, {
  String? note,
}) => transactions.add(
  amountMinor: minor,
  type: category == 'Salary' ? TransactionType.income : TransactionType.expense,
  categoryId: categories.byName(category).id,
  occurredAt: at,
  title: title,
  note: note,
);

/// Two this period, one before it.
Future<void> history() async {
  await add(
    1250,
    'Food',
    DateTime(2026, 11, 4, 8, 5),
    'Nasi lemak',
    note: 'egg',
  );
  await add(480000, 'Salary', DateTime(2026, 11, 1, 9), 'November pay');
  await add(9900, 'Shopping', DateTime(2026, 10, 10, 18), 'Shoes');
}

Future<void> tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> export(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(PrimaryButton, 'Export CSV'));
  await tester.pumpAndSettle();
}

List<String> lines() => sharer.shared.single.contents.split('\r\n');

void main() {
  group('S35 Export data', () {
    testWidgets('shows the intro, range and include options', (tester) async {
      await pumpExport(tester);
      expect(find.text('Export data'), findsOneWidget);
      expect(
        find.text(
          'Save your transactions as a CSV file you can open in Sheets or '
          'Excel, or import on a new phone.',
        ),
        findsOneWidget,
      );
      expect(find.text('RANGE'), findsOneWidget);
      expect(find.text('INCLUDE'), findsOneWidget);
      for (final label in ['This period', 'All time', 'Custom']) {
        expect(find.text(label), findsOneWidget);
      }
      for (final label in ['Expenses', 'Income', 'Notes']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('all time exports everything and shows the toast', (
      tester,
    ) async {
      await pumpExport(tester);
      await export(tester);
      final file = sharer.shared.single;
      expect(file.fileName, 'ctrlspend-2026-11-04.csv');
      expect(file.mimeType, 'text/csv');
      expect(lines(), [
        'date,time,type,category,title,amount,note',
        '2026-11-04,08:05,expense,Food,Nasi lemak,12.50,egg',
        '2026-11-01,09:00,income,Salary,November pay,4800.00,',
        '2026-10-10,18:00,expense,Shopping,Shoes,99.00,',
      ]);
      expect(find.text('Saved 3 transactions to Files'), findsOneWidget);
      expect(find.text('ctrlspend-2026-11-04.csv'), findsOneWidget);
      hideAppToast();
    });

    testWidgets('this period, without income or notes', (tester) async {
      await pumpExport(tester);
      await tap(tester, 'This period');
      await tap(tester, 'Income');
      await tap(tester, 'Notes');
      await export(tester);
      expect(lines(), [
        'date,time,type,category,title,amount',
        '2026-11-04,08:05,expense,Food,Nasi lemak,12.50',
      ]);
      expect(find.text('Saved 1 transaction to Files'), findsOneWidget);
      hideAppToast();
    });

    testWidgets('a custom range starts as this period and can change', (
      tester,
    ) async {
      await pumpExport(tester);
      await tap(tester, 'Custom');
      expect(find.text('15 Oct 2026'), findsOneWidget);
      expect(find.text('14 Nov 2026'), findsOneWidget);
      await tap(tester, 'To');
      await tap(tester, '1');
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(PrimaryButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 Nov 2026'), findsOneWidget);
      await export(tester);
      expect(lines().skip(1), [
        '2026-11-01,09:00,income,Salary,November pay,4800.00,',
      ]);
      hideAppToast();
    });

    testWidgets('nothing in range says so and shares nothing', (tester) async {
      await pumpExport(tester, seed: null);
      await export(tester);
      expect(sharer.shared, isEmpty);
      expect(find.text('No transactions to export'), findsOneWidget);
      hideAppToast();
    });

    testWidgets('no toast when the share sheet is dismissed', (tester) async {
      await pumpExport(tester, shares: false);
      await export(tester);
      expect(sharer.shared, hasLength(1));
      expect(find.textContaining('Saved'), findsNothing);
    });

    testWidgets('with neither type included Export is off', (tester) async {
      await pumpExport(tester);
      await tap(tester, 'Expenses');
      await tap(tester, 'Income');
      expect(
        tester
            .widget<PrimaryButton>(
              find.widgetWithText(PrimaryButton, 'Export CSV'),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('S21 opens it', (tester) async {
      await pumpExport(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      unawaited(container.read(appRouterProvider).push(Routes.settings));
      await tester.pumpAndSettle();
      await tap(tester, 'Export to CSV');
      expect(find.byType(ExportScreen), findsOneWidget);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('uses the theme in ${theme.name} mode', (tester) async {
      await pumpExport(tester, theme: theme);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(ExportScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
    });
  }
}
