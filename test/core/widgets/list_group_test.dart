import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

void main() {
  for (final t in themes) {
    testWidgets('a group is a surface card with dividers in ${t.name}', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        t.theme,
        ListGroup(
          children: [
            ListGroupRow(
              title: 'Month starts on',
              value: '15th',
              leading: const CategoryTile(
                icon: Icons.calendar_today_outlined,
                color: CategoryColorKey.orange,
              ),
              onTap: () {},
            ),
            ListGroupRow(title: 'Theme', value: 'System', onTap: () {}),
            const ListGroupRow(title: 'Currency', value: 'RM'),
          ],
        ),
      );
      final card = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ListGroup),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.color, t.colors.surface);
      expect(card.borderRadius, BorderRadius.circular(28));
      final dividers = tester.widgetList<Divider>(find.byType(Divider));
      expect(dividers, hasLength(2));
      expect(dividers.first.color, t.colors.divider);
      final value = tester.widget<Text>(find.text('15th'));
      expect(value.style!.color, t.colors.muted);
    });

    testWidgets('a key-value row in ${t.name}', (tester) async {
      await pumpThemed(
        tester,
        t.theme,
        const KeyValueRow(label: 'Category', value: 'Food'),
      );
      expect(tester.getSize(find.byType(KeyValueRow)).height, 58);
      final value = tester.widget<Text>(find.text('Food'));
      expect(value.style!.color, t.colors.ink);
      expect(value.style!.fontWeight, FontWeight.w600);
    });
  }

  testWidgets('rows are at least 64 high', (tester) async {
    await pumpThemed(
      tester,
      themes.first.theme,
      const ListGroup(children: [ListGroupRow(title: 'Export to CSV')]),
    );
    expect(
      tester.getSize(find.byType(ListGroupRow)).height,
      greaterThanOrEqualTo(64),
    );
  });

  testWidgets('a chevron shows only on tappable rows', (tester) async {
    var taps = 0;
    await pumpThemed(
      tester,
      themes.first.theme,
      ListGroup(
        children: [
          ListGroupRow(title: 'Categories', value: '8', onTap: () => taps++),
          const ListGroupRow(title: 'Read only'),
        ],
      ),
    );
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    await tester.tap(find.text('Categories'));
    expect(taps, 1);
  });

  testWidgets('rows read their title and value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(
      tester,
      themes.first.theme,
      ListGroup(
        children: [
          ListGroupRow(title: 'Theme', value: 'System', onTap: () {}),
          const ListGroupRow(title: 'Export to CSV'),
        ],
      ),
    );
    expect(
      tester.getSemantics(find.widgetWithText(ListGroupRow, 'Theme')),
      isSemantics(label: 'Theme, System', isButton: true),
    );
    expect(
      tester.getSemantics(find.widgetWithText(ListGroupRow, 'Export to CSV')),
      isSemantics(label: 'Export to CSV', isButton: false),
    );
    handle.dispose();
  });
}
