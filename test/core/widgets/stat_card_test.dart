import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/stat_card.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/themed.dart';

void main() {
  for (final t in themes) {
    testWidgets('a Home card with a tinted icon in ${t.name}', (tester) async {
      await pumpThemed(
        tester,
        t.theme,
        const StatCard(
          label: 'Spent',
          value: Text('RM 760'),
          semanticLabel: 'Spent, RM 760',
          icon: AppIcon.arrowUp,
          iconColor: CategoryColorKey.red,
        ),
      );
      expect(find.text('SPENT'), findsOneWidget);
      final label = tester.widget<Text>(find.text('SPENT'));
      expect(label.style!.color, t.colors.muted);

      final value = tester.widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text('RM 760'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      );
      expect(value.style.color, t.colors.ink);
      expect(value.style.fontSize, 21);

      final circle = tester.widget<Container>(
        find
            .ancestor(
              of: findAppIcon(AppIcon.arrowUp),
              matching: find.byType(Container),
            )
            .first,
      );
      final palette = t.categories.of(CategoryColorKey.red);
      expect((circle.decoration! as BoxDecoration).color, palette.tile);
      expect(
        tester.widget<AppIconView>(findAppIcon(AppIcon.arrowUp)).color,
        palette.icon,
      );
    });

    testWidgets('an Insights card with a caption in ${t.name}', (tester) async {
      await pumpThemed(
        tester,
        t.theme,
        const StatCard(
          label: 'Under pace',
          value: Text('6 of 7'),
          caption: 'days this week',
          semanticLabel: 'Under pace, 6 of 7 days this week',
        ),
      );
      expect(find.byType(AppIconView), findsNothing);
      final caption = tester.widget<Text>(find.text('days this week'));
      expect(caption.style!.color, t.colors.muted);
    });
  }

  testWidgets('reads as one label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(
      tester,
      themes.first.theme,
      const StatCard(
        label: 'Income',
        value: Text('RM 4,800'),
        semanticLabel: 'Income, RM 4,800',
        icon: AppIcon.arrowDown,
        iconColor: CategoryColorKey.green,
      ),
    );
    expect(find.bySemanticsLabel('Income, RM 4,800'), findsOneWidget);
    expect(find.bySemanticsLabel('INCOME'), findsNothing);
    handle.dispose();
  });
}
