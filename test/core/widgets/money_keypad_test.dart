import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:ctrl_spend/core/widgets/money_keypad_key.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int value;

  Future<void> pumpKeypad(
    WidgetTester tester, {
    ThemeData? theme,
    MoneyKeypadSize size = MoneyKeypadSize.full,
    int initial = 0,
  }) async {
    value = initial;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? buildLightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => MoneyKeypad(
              value: value,
              size: size,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    );
  }

  Finder key(String label) => find.bySemanticsLabel(label);

  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    for (final (size, height, radius, fill, pressed) in [
      (
        MoneyKeypadSize.full,
        56.0,
        AppRadius.r18,
        colors.surface,
        colors.raised,
      ),
      (
        MoneyKeypadSize.sheet,
        48.0,
        AppRadius.r16,
        colors.fillSoft,
        colors.keySoftPressed,
      ),
    ]) {
      testWidgets('${size.name} keys match the tokens in $name', (
        tester,
      ) async {
        await pumpKeypad(tester, theme: theme, size: size);

        expect(find.byType(MoneyKeypadKey), findsNWidgets(12));
        final one = find.ancestor(
          of: find.text('1'),
          matching: find.byType(MoneyKeypadKey),
        );
        expect(tester.getSize(one).height, height);
        final material = tester.widget<Material>(
          find.descendant(of: one, matching: find.byType(Material)),
        );
        expect(material.color, fill);
        expect(
          material.shape,
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        );
        final ink = tester.widget<InkWell>(
          find.descendant(of: one, matching: find.byType(InkWell)),
        );
        expect(ink.highlightColor, pressed);

        // 8 between keys, both ways.
        final two = tester.getRect(find.text('2'));
        final four = tester.getRect(find.text('4'));
        final r1 = tester.getRect(one);
        expect(
          tester
                  .getRect(
                    find.ancestor(
                      of: find.text('2'),
                      matching: find.byType(MoneyKeypadKey),
                    ),
                  )
                  .left -
              r1.right,
          8,
        );
        expect(four.top - two.top, height + 8);
      });
    }
  }

  testWidgets('typing fills from the cents; 00 and backspace work', (
    tester,
  ) async {
    await pumpKeypad(tester);

    for (final d in ['1', '2', '5', '0']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    expect(value, 1250);

    await tester.tap(key('Backspace'));
    await tester.pump();
    expect(value, 125);

    await tester.tap(key('Double zero'));
    expect(value, 12500);
  });

  testWidgets('keys past the 9-digit cap do not report a change', (
    tester,
  ) async {
    await pumpKeypad(tester, initial: 999999999);
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MoneyKeypad(value: 999999999, onChanged: (_) => calls++),
        ),
      ),
    );
    await tester.tap(find.text('1'));
    expect(calls, 0);
  });

  testWidgets('every key is a labelled button of at least 44px', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpKeypad(tester, size: MoneyKeypadSize.sheet);

    for (final label in [
      for (var d = 0; d <= 9; d++) '$d',
      'Double zero',
      'Backspace',
    ]) {
      expect(
        tester.getSemantics(key(label)),
        isSemantics(label: label, isButton: true),
        reason: label,
      );
      final size = tester.getSize(key(label));
      expect(size.height, greaterThanOrEqualTo(44), reason: label);
      expect(size.width, greaterThanOrEqualTo(44), reason: label);
    }
    handle.dispose();
  });
}
