import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/widgets/amount_display.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:ctrl_spend/core/widgets/money_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    ThemeData? theme,
    int minor = 200000,
    MoneyKeypadSize size = MoneyKeypadSize.full,
    double width = 390,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: theme ?? buildLightTheme(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: AmountDisplay(
              minor: minor,
              currency: Currency.myr,
              size: size,
              label: 'PER MONTH',
              caption: 'per month',
              semanticLabel: 'Budget RM 2,000.00 per month',
            ),
          ),
        ),
      ),
    ),
  );

  TextSpan amountSpan(WidgetTester tester) =>
      tester
              .widget<Text>(
                find.descendant(
                  of: find.byType(AmountText),
                  matching: find.byType(Text),
                ),
              )
              .textSpan!
          as TextSpan;

  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    for (final (size, fontSize) in [
      (MoneyKeypadSize.full, 56.0),
      (MoneyKeypadSize.sheet, 40.0),
    ]) {
      testWidgets('${size.name}: smaller symbol, muted cents in $name', (
        tester,
      ) async {
        await pump(tester, theme: theme, size: size);

        final (symbol, whole, cents) = switch (amountSpan(tester).children!) {
          [final TextSpan a, final TextSpan b, final TextSpan c] => (a, b, c),
          _ => throw StateError('expected 3 spans'),
        };
        expect([symbol.text, whole.text, cents.text], ['RM ', '2,000', '.00']);
        final base = amountSpan(tester).style!;
        expect(base.fontSize, fontSize);
        expect(base.color, colors.ink);
        expect(symbol.style!.fontSize, closeTo(fontSize * 0.45, 0.01));
        expect(cents.style!.fontSize, closeTo(fontSize * 0.45, 0.01));
        expect(cents.style!.color, colors.muted);
        expect(find.text('PER MONTH'), findsOneWidget);
        expect(find.text('per month'), findsOneWidget);
      });
    }
  }

  testWidgets('reads as one live region with the given label', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    expect(
      tester.getSemantics(find.byType(AmountDisplay)),
      isSemantics(label: 'Budget RM 2,000.00 per month', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('nine digits scale down to fit a narrow width', (tester) async {
    await pump(tester, minor: 999999999, width: 280);

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(FittedBox)).width,
      lessThanOrEqualTo(280),
    );
  });
}
