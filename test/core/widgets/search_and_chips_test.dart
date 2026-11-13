import 'package:ctrl_spend/core/widgets/filter_chips.dart';
import 'package:ctrl_spend/core/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

void main() {
  for (final t in themes) {
    testWidgets('search field: surface pill and muted hint in ${t.name}', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpThemed(
        tester,
        t.theme,
        SearchField(controller: controller, hint: 'Search', onChanged: (_) {}),
      );
      final decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(decoration.fillColor, t.colors.surface);
      expect(decoration.hintStyle!.color, t.colors.muted);
      expect(tester.getSize(find.byType(SearchField)).height, 52);
    });

    testWidgets('chips: ink when selected in ${t.name}', (tester) async {
      await pumpThemed(
        tester,
        t.theme,
        FilterChips<int>(
          chips: const [(value: 0, label: 'All'), (value: 1, label: 'Food')],
          selected: 0,
          onChanged: (_) {},
        ),
      );
      Material fill(String label) => tester.widget<Material>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Material))
            .first,
      );
      expect(fill('All').color, t.colors.ink);
      expect(fill('Food').color, t.colors.surface);
      expect(
        tester.widget<Text>(find.text('Food')).style!.color,
        t.colors.chipText,
      );
      expect(tester.getSize(find.byType(FilterChips<int>)).height, 44);
    });
  }

  testWidgets('the clear button shows with text and clears it', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <String>[];
    await pumpThemed(
      tester,
      themes.first.theme,
      SearchField(
        controller: controller,
        hint: 'Search',
        onChanged: changes.add,
      ),
    );
    expect(find.byTooltip('Clear search'), findsNothing);
    await tester.enterText(find.byType(TextField), 'nasi');
    await tester.pump();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(changes.last, '');
    expect(find.byTooltip('Clear search'), findsNothing);
  });

  testWidgets('chips report taps and read as selected', (tester) async {
    final handle = tester.ensureSemantics();
    int? picked;
    await pumpThemed(
      tester,
      themes.first.theme,
      FilterChips<int>(
        chips: const [(value: 0, label: 'All'), (value: 1, label: 'Food')],
        selected: 0,
        onChanged: (v) => picked = v,
      ),
    );
    await tester.tap(find.text('Food'));
    expect(picked, 1);
    expect(
      tester.getSemantics(find.text('All')),
      isSemantics(label: 'All', isSelected: true, isButton: true),
    );
    handle.dispose();
  });
}
