import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_shadows.dart';
import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_shell.dart';
import 'package:ctrl_spend/core/widgets/app_shell_tab.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';

void main() {
  late List<int> selected;
  late int adds;

  Future<void> pumpShell(
    WidgetTester tester, {
    ThemeData? theme,
    int currentIndex = 0,
    Size size = const Size(390, 844),
  }) async {
    selected = [];
    adds = 0;
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? buildLightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppShell(
          currentIndex: currentIndex,
          onTabSelected: selected.add,
          onAdd: () => adds++,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Finder tab(String label) =>
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == label);

  for (final (name, theme, colors, shadows) in [
    ('light', buildLightTheme(), AppColors.light, AppShadows.light),
    ('dark', buildDarkTheme(), AppColors.dark, AppShadows.dark),
  ]) {
    testWidgets('matches the design tokens and layout in $name', (
      tester,
    ) async {
      await pumpShell(tester, theme: theme);

      // Bar: 278 x 68, 16 from the left, 24 from the bottom of 844.
      final bar = find
          .ancestor(of: find.byType(Row), matching: find.byType(DecoratedBox))
          .first;
      expect(tester.getRect(bar), const Rect.fromLTWH(16, 752, 278, 68));
      final barBox =
          tester.widget<DecoratedBox>(bar).decoration as BoxDecoration;
      expect(barBox.color, colors.surface);
      expect(barBox.boxShadow, shadows.bottomBar);

      // Add button: 64 circle, 16 from the right, 26 from the bottom.
      final add = find.byTooltip('Add transaction');
      expect(tester.getRect(add), const Rect.fromLTWH(310, 754, 64, 64));
      final addBox =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: add,
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(addBox.boxShadow, shadows.addButton);
      final addFill = tester.widget<Material>(
        find.descendant(of: add, matching: find.byType(Material)),
      );
      expect(addFill.color, colors.ink);
      expect(
        tester.widget<AppIconView>(findAppIcon(AppIcon.add)).color,
        colors.onInk,
      );

      // Only the active tab shows its label, on a navSelected pill.
      expect(find.text('Home'), findsOneWidget);
      for (final other in ['Activity', 'Budgets', 'Insights']) {
        expect(find.text(other), findsNothing);
      }
      final pill = tester.widget<Material>(
        find.descendant(of: tab('Home'), matching: find.byType(Material)),
      );
      expect(pill.color, colors.navSelected);
    });
  }

  testWidgets('every tab and the add button is a labelled 44px target', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpShell(tester, currentIndex: 2);

    for (final label in ['Home', 'Activity', 'Budgets', 'Insights']) {
      final size = tester.getSize(tab(label));
      expect(size.width, greaterThanOrEqualTo(44), reason: label);
      expect(size.height, greaterThanOrEqualTo(44), reason: label);
      expect(
        tester.getSemantics(tab(label)),
        isSemantics(
          label: label,
          isButton: true,
          isSelected: label == 'Budgets',
        ),
      );
    }
    expect(find.bySemanticsLabel('Add transaction'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('taps report the tab index and the add press', (tester) async {
    await pumpShell(tester);

    await tester.tap(tab('Insights'));
    await tester.tap(tab('Home'));
    await tester.tap(find.byTooltip('Add transaction'));

    expect(selected, [3, 0]);
    expect(adds, 1);
  });

  testWidgets('the bar shrinks to clear the add button on narrow phones', (
    tester,
  ) async {
    await pumpShell(tester, size: const Size(320, 640), currentIndex: 3);

    final barRight = tester.getRect(tab('Budgets')).right;
    final addLeft = tester.getRect(find.byTooltip('Add transaction')).left;
    expect(barRight, lessThan(addLeft));
    for (final label in ['Home', 'Activity', 'Budgets', 'Insights']) {
      expect(tester.getSize(tab(label)).width, greaterThanOrEqualTo(44));
    }
    expect(tester.takeException(), isNull);
  });
}
