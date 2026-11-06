import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

double fillFraction(WidgetTester tester) => tester
    .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
    .widthFactor!;

Color? shapeColor(WidgetTester tester, Finder finder) =>
    (tester.widget<DecoratedBox>(finder).decoration as ShapeDecoration).color;

void main() {
  Widget bar(double value, {Color? color, bool onHero = false}) => SizedBox(
    width: 300,
    child: AppProgressBar(
      value: value,
      semanticLabel: '38% of monthly budget spent',
      color: color,
      onHero: onHero,
    ),
  );

  for (final t in themes) {
    testWidgets('ink fill on a raised track in ${t.name}', (tester) async {
      await pumpThemed(tester, t.theme, bar(0.38));
      final boxes = find.descendant(
        of: find.byType(AppProgressBar),
        matching: find.byType(DecoratedBox),
      );
      expect(shapeColor(tester, boxes.first), t.colors.raised);
      expect(shapeColor(tester, boxes.last), t.colors.ink);
      expect(tester.getSize(find.byType(AppProgressBar)).height, 10);
    });

    testWidgets('the hero style in ${t.name}', (tester) async {
      await pumpThemed(tester, t.theme, bar(0.5, onHero: true));
      final boxes = find.descendant(
        of: find.byType(AppProgressBar),
        matching: find.byType(DecoratedBox),
      );
      expect(shapeColor(tester, boxes.first), t.colors.heroTrack);
      expect(shapeColor(tester, boxes.last), Colors.white);
    });

    testWidgets('a status colour fills the bar in ${t.name}', (tester) async {
      await pumpThemed(tester, t.theme, bar(0.82, color: t.colors.warning));
      final fill = find
          .descendant(
            of: find.byType(AppProgressBar),
            matching: find.byType(DecoratedBox),
          )
          .last;
      expect(shapeColor(tester, fill), t.colors.warning);
    });
  }

  testWidgets('fills in proportion and clamps to 0–1', (tester) async {
    for (final (value, expected) in [
      (0.0, 0.0),
      (0.5, 0.5),
      (1.2, 1.0),
      (-0.1, 0.0),
      (double.nan, 0.0),
    ]) {
      await pumpThemed(tester, themes.first.theme, bar(value));
      expect(fillFraction(tester), expected, reason: '$value');
    }
  });

  testWidgets('reads its label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(tester, themes.first.theme, bar(0.38));
    expect(
      find.bySemanticsLabel('38% of monthly budget spent'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
