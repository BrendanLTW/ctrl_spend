import 'package:ctrl_spend/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

void main() {
  for (final t in themes) {
    testWidgets('surface fill, muted hint and icon in ${t.name}', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpThemed(
        tester,
        t.theme,
        AppTextField(
          controller: controller,
          hint: 'First name',
          icon: Icons.person_outline_rounded,
        ),
      );
      final decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(decoration.fillColor, t.colors.surface);
      expect(decoration.hintStyle!.color, t.colors.muted);
      expect(
        (decoration.enabledBorder! as OutlineInputBorder).borderRadius,
        BorderRadius.circular(20),
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.person_outline_rounded)).color,
        t.colors.muted,
      );
      expect(
        tester.getSize(find.byType(AppTextField)).height,
        greaterThanOrEqualTo(56),
      );
    });
  }

  testWidgets('maxLength stops typing without a counter', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpThemed(
      tester,
      themes.first.theme,
      AppTextField(controller: controller, hint: 'Name', maxLength: 5),
    );
    await tester.enterText(find.byType(TextField), 'Alexander');
    expect(controller.text, 'Alexa');
    expect(find.text('5/5'), findsNothing);
  });

  testWidgets('the hint labels it for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpThemed(
      tester,
      themes.first.theme,
      AppTextField(controller: controller, hint: 'First name'),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('First name')),
      isSemantics(label: 'First name', isTextField: true),
    );
    handle.dispose();
  });
}
