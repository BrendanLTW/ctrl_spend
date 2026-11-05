import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('light and dark define all 20 tokens', () {
      expect(AppColors.light.tokens, hasLength(20));
      expect(AppColors.dark.tokens.keys, AppColors.light.tokens.keys);
    });

    test('lerp returns each end at 0 and 1', () {
      const light = AppColors.light;
      const dark = AppColors.dark;
      expect(light.lerp(dark, 0).tokens, light.tokens);
      expect(light.lerp(dark, 1).tokens, dark.tokens);
    });

    test('copyWith changes only the given token', () {
      const red = Color(0xFFFF0000);
      final copy = AppColors.light.copyWith(muted: red);
      expect(copy.tokens, {...AppColors.light.tokens, 'muted': red});
    });

    testWidgets('context.colors reads the theme extension', (tester) async {
      late AppColors colors;
      await tester.pumpWidget(
        Theme(
          data: ThemeData(extensions: const [AppColors.dark]),
          child: Builder(
            builder: (context) {
              colors = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(colors, same(AppColors.dark));
    });
  });

  group('CategoryColors', () {
    test('light and dark cover every colour key', () {
      expect(CategoryColors.light.tiles.keys, CategoryColorKey.values);
      expect(CategoryColors.dark.tiles.keys, CategoryColorKey.values);
    });

    test('lerp returns each end at 0 and 1', () {
      const light = CategoryColors.light;
      const dark = CategoryColors.dark;
      expect(light.lerp(dark, 0).tiles, light.tiles);
      expect(light.lerp(dark, 1).tiles, dark.tiles);
    });
  });
}
