import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/features/activity/presentation/activity_screen.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_checking_view.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_done_view.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_failed_view.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_review_view.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/presentation/settings_screen.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_category_repository.dart';
import '../../../helpers/fake_csv_file_picker.dart';
import '../../../helpers/fake_file_sharer.dart';
import '../../../helpers/fake_preferences_repository.dart';
import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fake_transaction_repository.dart';

late FakeTransactionRepository transactions;
late FakeCategoryRepository categories;
late FakeCsvFilePicker picker;
late FakeFileSharer sharer;
late ProviderContainer container;

const header = 'date,time,type,category,title,amount,note';
const good =
    '$header\r\n'
    '2026-11-04,08:05,expense,Food,Nasi lemak,12.50,with egg\r\n'
    '2026-11-01,09:00,income,Salary,November pay,4800.00,\r\n';
const bad =
    '$header\r\n'
    '2026-11-04,08:05,expense,Food,ok,1.00,\r\n'
    '31/02/2026,08:05,expense,Food,x,1.00,\r\n'
    '2026-11-04,08:05,expense,Food,x,,\r\n';

Future<void> pumpSettings(
  WidgetTester tester, {
  AppTheme theme = AppTheme.system,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  categories = FakeCategoryRepository();
  transactions = FakeTransactionRepository()
    ..categoryForImport = categories.idForImport;
  picker = FakeCsvFilePicker();
  sharer = FakeFileSharer();
  container = ProviderContainer(
    overrides: [
      ...fakeRepositories(
        preferences: FakePreferencesRepository(
          Preferences(onboardingComplete: true, theme: theme),
        ),
        categories: categories,
        transactions: transactions,
        picker: picker,
        sharer: sharer,
      ),
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
}

Future<void> tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> importFile(WidgetTester tester, String name, String text) async {
  picker.willPick(name, text);
  await tester.scrollUntilVisible(find.text('Import from CSV'), 200);
  // Built isn't on screen: bring the whole row into view.
  await tester.ensureVisible(find.text('Import from CSV'));
  await tester.pumpAndSettle();
  await tap(tester, 'Import from CSV');
}

/// Imports [text] through S52 with its default choices.
Future<void> importAndConfirm(
  WidgetTester tester,
  String name,
  String text,
) async {
  await importFile(tester, name, text);
  await tester.tap(find.byType(PrimaryButton));
  await tester.pumpAndSettle();
}

String kv(WidgetTester tester, String label) =>
    tester.widget<KeyValueRow>(find.widgetWithText(KeyValueRow, label)).value;

void main() {
  group('S51 Checking file', () {
    // The check itself runs in one test frame, so the view is pumped on
    // its own; progress and cancelling are covered in csv_import_test.
    Future<void> pumpChecking(WidgetTester tester, AppTheme theme) async {
      await pumpSettings(tester, theme: theme);
      Navigator.of(tester.element(find.byType(SettingsScreen))).push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            body: ImportCheckingView(
              fileName: 'ctrlspend-2026-11-04.csv',
              checked: 128,
              total: 214,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('shows the row, the file and a progress bar', (tester) async {
      await pumpChecking(tester, AppTheme.light);
      expect(find.text('Checking your file'), findsOneWidget);
      expect(
        find.text('Row 128 of 214 · ctrlspend-2026-11-04.csv'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Checking file, 60%'), findsOneWidget);
      expect(
        find.text(
          'Every row is checked before anything is imported. If any row has '
          'a problem, nothing changes.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ImportCheckingView), findsNothing);
    });
  });

  group('S52 Review', () {
    testWidgets('summarises a clean file and saves nothing yet', (
      tester,
    ) async {
      await pumpSettings(tester);
      await importFile(
        tester,
        'ctrlspend-2026-11-04.csv',
        '$good'
            '2026-10-02,12:00,expense,Coffee,Latte,9.00,\r\n'
            '2026-10-03,12:00,expense,coffee,Mocha,9.50,\r\n',
      );
      expect(find.byType(ImportReviewView), findsOneWidget);
      expect(transactions.all, isEmpty);
      expect(find.text('ctrlspend-2026-11-04.csv'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^4 rows · \d+ B$')), findsOneWidget);
      expect(find.text('All 4 rows look good.'), findsOneWidget);
      expect(kv(tester, 'Dates'), '2 Oct – 4 Nov 2026');
      expect(kv(tester, 'Expenses · Income'), '3 · 1');
      expect(kv(tester, 'New categories'), 'Coffee');
      expect(find.text('Skip duplicates'), findsNothing, reason: 'none');
      expect(
        find.text(
          "Imports add to your data and can't be undone. Export a CSV first "
          'if you want a backup.',
        ),
        findsOneWidget,
      );
      expect(find.text('Import 4 transactions'), findsOneWidget);
    });

    testWidgets('no new categories, no row for them', (tester) async {
      await pumpSettings(tester);
      await importFile(tester, 'a.csv', good);
      expect(find.text('New categories'), findsNothing);
    });

    testWidgets('duplicates are skipped by default, or imported anyway', (
      tester,
    ) async {
      await pumpSettings(tester);
      await importAndConfirm(tester, 'a.csv', good);
      await tap(tester, 'Back to Settings');
      await importFile(
        tester,
        'b.csv',
        '$good'
            '2026-11-02,12:00,expense,Food,Lunch,8.00,\r\n',
      );
      expect(
        find.text('2 ROWS MATCH TRANSACTIONS YOU ALREADY HAVE'),
        findsOneWidget,
      );
      expect(find.text('Same date, amount and category'), findsOneWidget);
      expect(find.text('Import 1 transaction'), findsOneWidget);
      await tap(tester, 'Import them anyway');
      expect(find.text('Import 3 transactions'), findsOneWidget);
      await tap(tester, 'Skip duplicates');
      await tester.tap(find.text('Import 1 transaction'));
      await tester.pumpAndSettle();
      expect(transactions.all, hasLength(3));
    });

    testWidgets('only duplicates: nothing to import unless anyway', (
      tester,
    ) async {
      await pumpSettings(tester);
      await importAndConfirm(tester, 'a.csv', good);
      await tap(tester, 'Back to Settings');
      await importFile(tester, 'a.csv', good);
      expect(
        tester
            .widget<PrimaryButton>(
              find.widgetWithText(PrimaryButton, 'Import 0 transactions'),
            )
            .onPressed,
        isNull,
      );
      await tap(tester, 'Import them anyway');
      await tester.tap(find.text('Import 2 transactions'));
      await tester.pumpAndSettle();
      expect(transactions.all, hasLength(4));
    });

    testWidgets('Change checks another file', (tester) async {
      await pumpSettings(tester);
      await importFile(tester, 'a.csv', good);
      picker.willPick('b.csv', bad);
      await tap(tester, 'Change');
      expect(find.byType(ImportFailedView), findsOneWidget);
      expect(find.text('B.CSV'), findsOneWidget);
    });

    testWidgets('Change, then cancelling the picker keeps the review', (
      tester,
    ) async {
      await pumpSettings(tester);
      await importFile(tester, 'a.csv', good);
      await tap(tester, 'Change');
      expect(find.text('All 2 rows look good.'), findsOneWidget);
    });
  });

  group('S53 Success', () {
    testWidgets('says what was imported, skipped and added', (tester) async {
      await pumpSettings(tester);
      await importAndConfirm(tester, 'a.csv', good);
      await tap(tester, 'Back to Settings');
      await importAndConfirm(
        tester,
        'b.csv',
        '$good'
            '2026-09-20,12:00,expense,Coffee,Latte,9.00,\r\n'
            '2026-10-20,12:00,expense,Parking,KLCC,5.00,\r\n',
      );
      expect(find.byType(ImportDoneView), findsOneWidget);
      expect(find.text('Imported 2 transactions'), findsOneWidget);
      expect(
        find.text(
          '2 duplicates were skipped. Two new categories were added: Coffee '
          'and Parking.',
        ),
        findsOneWidget,
      );
      expect(kv(tester, 'Expenses'), '2');
      expect(kv(tester, 'Income'), '0');
      // Periods start on the 1st by default.
      expect(kv(tester, 'Periods updated'), 'Sep – Oct 2026');
      expect(categories.byName('Parking').colorKey, CategoryColorKey.neutral);
    });

    testWidgets('a plain import has no extra line', (tester) async {
      await pumpSettings(tester);
      await importAndConfirm(tester, 'a.csv', good);
      expect(find.text('Imported 2 transactions'), findsOneWidget);
      expect(find.textContaining('skipped'), findsNothing);
      expect(kv(tester, 'Periods updated'), 'Nov 2026');
      expect(transactions.all.map((t) => t.title), [
        'Nasi lemak',
        'November pay',
      ]);
      expect(transactions.all.first.categoryId, categories.byName('Food').id);
    });

    testWidgets('See in Activity opens Activity', (tester) async {
      await pumpSettings(tester);
      await importAndConfirm(tester, 'a.csv', good);
      await tap(tester, 'See in Activity');
      expect(find.byType(ActivityScreen), findsOneWidget);
    });

    testWidgets('Back to Settings closes the flow', (tester) async {
      await pumpSettings(tester);
      await importAndConfirm(tester, 'a.csv', good);
      await tap(tester, 'Back to Settings');
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  testWidgets('cancelling the picker does nothing', (tester) async {
    await pumpSettings(tester);
    await tester.scrollUntilVisible(find.text('Import from CSV'), 200);
    // Built isn't on screen: bring the whole row into view.
    await tester.ensureVisible(find.text('Import from CSV'));
    await tester.pumpAndSettle();
    await tap(tester, 'Import from CSV');
    expect(picker.picks, 1);
    expect(transactions.all, isEmpty);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('unknown categories are created', (tester) async {
    await pumpSettings(tester);
    await importAndConfirm(
      tester,
      'pets.csv',
      'date,type,category,amount\r\n2026-11-04,expense,Pets,20\r\n',
    );
    final pets = categories.byName('Pets');
    expect(pets.colorKey, CategoryColorKey.neutral);
    expect(transactions.all.single.categoryId, pets.id);
    expect(transactions.all.single.title, 'Pets');
  });

  testWidgets('a header with no rows says so and closes', (tester) async {
    await pumpSettings(tester);
    await importFile(tester, 'empty.csv', header);
    expect(find.text('That file has no transactions'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);
    hideAppToast();
  });

  group('S36 Import failed', () {
    testWidgets('lists every problem and imports nothing', (tester) async {
      await pumpSettings(tester);
      await importFile(tester, 'bank-export.csv', bad);
      expect(find.byType(ImportFailedView), findsOneWidget);
      expect(transactions.all, isEmpty);
      expect(find.text('Import data'), findsOneWidget);
      expect(find.text("We couldn't import that file"), findsOneWidget);
      expect(
        find.text(
          '2 rows have problems, so nothing was imported. Fix them and try '
          'again.',
        ),
        findsOneWidget,
      );
      expect(find.text('BANK-EXPORT.CSV'), findsOneWidget);
      final rows = {
        for (final r in tester.widgetList<ListGroupRow>(
          find.byType(ListGroupRow),
        ))
          r.title: r.subtitle,
      };
      expect(rows, {
        'Row 3': "“31/02/2026” isn't a real date",
        'Row 4': 'Amount is empty',
      });
    });

    testWidgets('a file that is not text is one problem', (tester) async {
      await pumpSettings(tester);
      picker.files.add((name: 'photo.csv', bytes: [0xff, 0xfe, 0x00]));
      await tester.scrollUntilVisible(find.text('Import from CSV'), 200);
      // Built isn't on screen: bring the whole row into view.
      await tester.ensureVisible(find.text('Import from CSV'));
      await tester.pumpAndSettle();
      await tap(tester, 'Import from CSV');
      expect(find.text("The file isn't readable text"), findsOneWidget);
      expect(
        find.text(
          '1 row has a problem, so nothing was imported. '
          'Fix it and try again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Choose another file can go on to review', (tester) async {
      await pumpSettings(tester);
      await importFile(tester, 'bank-export.csv', bad);
      picker.willPick('fixed.csv', good);
      await tap(tester, 'Choose another file');
      expect(find.byType(ImportFailedView), findsNothing);
      expect(find.text('All 2 rows look good.'), findsOneWidget);
    });

    testWidgets('Choose another file can fail again; Back goes to Settings', (
      tester,
    ) async {
      await pumpSettings(tester);
      await importFile(tester, 'bank-export.csv', bad);
      picker.willPick('worse.csv', 'date,title\r\n2026-11-04,x\r\n');
      await tap(tester, 'Choose another file');
      expect(find.text('WORSE.CSV'), findsOneWidget);
      expect(
        find.text('The first row must name the columns type, category, amount'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('Download a sample CSV shares the sample', (tester) async {
      await pumpSettings(tester);
      await importFile(tester, 'bank-export.csv', bad);
      await tap(tester, 'Download a sample CSV');
      final file = sharer.shared.single;
      expect(file.fileName, 'ctrlspend-sample.csv');
      expect(file.contents, sampleCsv);
    });
  });

  for (final (theme, colors) in [
    (AppTheme.light, AppColors.light),
    (AppTheme.dark, AppColors.dark),
  ]) {
    testWidgets('the flow uses the theme in ${theme.name} mode', (
      tester,
    ) async {
      await pumpSettings(tester, theme: theme);
      await importFile(tester, 'a.csv', good);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
        colors.ground,
      );
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Imported 2 transactions')).style!.color,
        colors.ink,
      );
    });
  }
}
