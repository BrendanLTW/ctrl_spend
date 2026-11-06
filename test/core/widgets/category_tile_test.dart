import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

void main() {
  test('every icon key has an icon', () {
    final icons = {for (final key in CategoryIconKey.values) categoryIcon(key)};
    expect(icons, hasLength(CategoryIconKey.values.length));
  });

  for (final t in themes) {
    testWidgets('uses the palette tile and icon colours in ${t.name}', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        t.theme,
        CategoryTile.forKey(
          CategoryIconKey.food,
          color: CategoryColorKey.orange,
        ),
      );
      final box = tester.widget<Container>(find.byType(Container));
      final decoration = box.decoration! as BoxDecoration;
      final palette = t.categories.of(CategoryColorKey.orange);
      expect(decoration.color, palette.tile);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, categoryIcon(CategoryIconKey.food));
      expect(icon.color, palette.icon);
      expect(tester.getSize(find.byType(Container)), const Size(48, 48));
    });
  }

  testWidgets('the compact size is 44 with radius 15', (tester) async {
    await pumpThemed(
      tester,
      themes.first.theme,
      const CategoryTile(
        icon: Icons.settings,
        color: CategoryColorKey.purple,
        size: CategoryTileSize.compact,
      ),
    );
    expect(tester.getSize(find.byType(Container)), const Size(44, 44));
    final decoration =
        tester.widget<Container>(find.byType(Container)).decoration!
            as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(15));
  });

  testWidgets('is hidden from screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(
      tester,
      themes.first.theme,
      CategoryTile.forKey(
        CategoryIconKey.gift,
        color: CategoryColorKey.neutral,
      ),
    );
    final outer = tester.widget<ExcludeSemantics>(
      find
          .descendant(
            of: find.byType(CategoryTile),
            matching: find.byType(ExcludeSemantics),
          )
          .first,
    );
    expect(outer.excluding, isTrue);
    expect(outer.child, isA<Container>());
    handle.dispose();
  });
}
