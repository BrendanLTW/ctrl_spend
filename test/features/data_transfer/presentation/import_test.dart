import 'dart:async';

import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/data_transfer/domain/csv_import.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/import_failed_screen.dart';
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
  await tap(tester, 'Import from CSV');
}

void main() {
  testWidgets('a clean file is imported with a toast', (tester) async {
    await pumpSettings(tester);
    await importFile(tester, 'ctrlspend-2026-11-04.csv', good);
    expect(transactions.all.map((t) => t.title), [
      'Nasi lemak',
      'November pay',
    ]);
    expect(transactions.all.first.categoryId, categories.byName('Food').id);
    expect(find.text('Imported 2 transactions'), findsOneWidget);
    expect(find.byType(ImportFailedScreen), findsNothing);
    hideAppToast();
  });

  testWidgets('cancelling the picker does nothing', (tester) async {
    await pumpSettings(tester);
    await tester.scrollUntilVisible(find.text('Import from CSV'), 200);
    await tap(tester, 'Import from CSV');
    expect(picker.picks, 1);
    expect(transactions.all, isEmpty);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('unknown categories are created', (tester) async {
    await pumpSettings(tester);
    await importFile(
      tester,
      'pets.csv',
      'date,type,category,amount\r\n2026-11-04,expense,Pets,20\r\n',
    );
    final pets = categories.byName('Pets');
    expect(pets.colorKey, CategoryColorKey.neutral);
    expect(transactions.all.single.categoryId, pets.id);
    expect(transactions.all.single.title, 'Pets');
    hideAppToast();
  });

  testWidgets('a header with no rows says so', (tester) async {
    await pumpSettings(tester);
    await importFile(tester, 'empty.csv', header);
    expect(find.text('That file has no transactions'), findsOneWidget);
    expect(find.byType(ImportFailedScreen), findsNothing);
    hideAppToast();
  });

  group('S36 Import failed', () {
    testWidgets('lists every problem and imports nothing', (tester) async {
      await pumpSettings(tester);
      await importFile(tester, 'bank-export.csv', bad);
      expect(find.byType(ImportFailedScreen), findsOneWidget);
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

    testWidgets('Choose another file can succeed and close it', (tester) async {
      await pumpSettings(tester);
      await importFile(tester, 'bank-export.csv', bad);
      picker.willPick('fixed.csv', good);
      await tap(tester, 'Choose another file');
      expect(find.byType(ImportFailedScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(transactions.all, hasLength(2));
      expect(find.text('Imported 2 transactions'), findsOneWidget);
      hideAppToast();
    });

    testWidgets('Choose another file can fail again', (tester) async {
      await pumpSettings(tester);
      await importFile(tester, 'bank-export.csv', bad);
      picker.willPick('worse.csv', 'date,title\r\n2026-11-04,x\r\n');
      await tap(tester, 'Choose another file');
      expect(find.text('WORSE.CSV'), findsOneWidget);
      expect(
        find.text('The first row must name the columns type, category, amount'),
        findsOneWidget,
      );
      // Replaced, not stacked: Back returns to Settings.
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
    testWidgets('S36 uses the theme in ${theme.name} mode', (tester) async {
      await pumpSettings(tester, theme: theme);
      await importFile(tester, 'bank-export.csv', bad);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(ImportFailedScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor,
        colors.ground,
      );
    });
  }
}
