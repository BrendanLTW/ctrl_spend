import 'package:ctrlspend/core/theme/app_colors.dart';
import 'package:ctrlspend/core/theme/category_palette.dart';
import 'package:ctrlspend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('light and dark define all 33 tokens', () {
      expect(AppColors.light.tokens, hasLength(33));
      expect(AppColors.dark.tokens.keys, AppColors.light.tokens.keys);
    });

    test('the 15 Nov tokens match DESIGN §3.2–3.3', () {
      expect(AppColors.light.buttonDisabled, const Color(0xFFD0D5DD));
      expect(AppColors.dark.onButtonDisabled, const Color(0xFF667085));
      // rgba(16,24,40,.42) and rgba(0,0,0,.6).
      expect(AppColors.light.scrim, const Color(0x6B101828));
      expect(AppColors.dark.scrim, const Color(0x99000000));
      expect(
        (AppColors.light.errorBox, AppColors.light.onErrorBox),
        (const Color(0xFFFEE4E2), const Color(0xFFB42318)),
      );
      // red at 16%.
      expect(AppColors.dark.errorBox, const Color(0x29F04438));
      expect(AppColors.dark.infoBox, const Color(0xFF1C2536));
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
