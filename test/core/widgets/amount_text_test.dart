import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/amount_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    testWidgets('shows smaller muted cents in $name', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => AmountText(
              124000,
              currency: Currency.myr,
              style: context.text.amount,
            ),
          ),
        ),
      );

      final span = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
      expect(span.toPlainText(), 'RM 1,240.00');
      final cents = span.children!.last as TextSpan;
      expect(cents.text, '.00');
      expect(cents.style!.fontSize, 18);
      expect(cents.style!.color, colors.muted);
      expect(span.style!.fontSize, 32);

      expect(find.bySemanticsLabel('RM 1,240.00'), findsOneWidget);
      handle.dispose();
    });
  }

  testWidgets('applies the sign and a custom cents style', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const AmountText(
          1250,
          currency: Currency.usd,
          sign: MoneySign.expense,
          style: TextStyle(fontSize: 20),
          centsStyle: TextStyle(fontSize: 10),
        ),
      ),
    );

    final span = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
    expect(span.toPlainText(), '${MoneyFormatter.minus}${r'$'} 12.50');
    expect((span.children!.last as TextSpan).style!.fontSize, 10);
  });

  testWidgets('symbolStyle styles the sign and symbol only', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const AmountText(
          -200000,
          currency: Currency.myr,
          style: TextStyle(fontSize: 56),
          symbolStyle: TextStyle(fontSize: 25),
        ),
      ),
    );

    final span = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
    final parts = span.children!.cast<TextSpan>();
    expect(parts.map((p) => p.text), [
      '${MoneyFormatter.minus}RM ',
      '2,000',
      '.00',
    ]);
    expect(parts.first.style!.fontSize, 25);
    expect(parts[1].style, isNull);
  });
}
