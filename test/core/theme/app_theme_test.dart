import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_shadows.dart';
import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/theme/theme_mode_controller.dart';
import 'package:ctrl_spend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sample extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Body copy', style: context.text.body),
          const Text('Default'),
          Text('RM 1,240', style: context.text.amount),
        ],
      ),
    );
  }
}

void main() {
  for (final (name, theme, colors, shadows) in [
    ('light', buildLightTheme(), AppColors.light, AppShadows.light),
    ('dark', buildDarkTheme(), AppColors.dark, AppShadows.dark),
  ]) {
    group('$name theme', () {
      Future<BuildContext> pumpSample(WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(theme: theme, home: const _Sample()),
        );
        return tester.element(find.byType(_Sample));
      }

      TextStyle styleOf(WidgetTester tester, String text) =>
          tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

      testWidgets('screen background is ground', (tester) async {
        await pumpSample(tester);
        final scaffold = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(Scaffold),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(scaffold.color, colors.ground);
      });

      testWidgets('text is Poppins in ink with tabular figures', (
        tester,
      ) async {
        await pumpSample(tester);
        for (final text in ['Body copy', 'Default', 'RM 1,240']) {
          final style = styleOf(tester, text);
          expect(style.fontFamily, 'Poppins', reason: text);
          expect(style.color, colors.ink, reason: text);
        }
        expect(
          styleOf(tester, 'RM 1,240').fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      });

      testWidgets('extensions resolve from context', (tester) async {
        final context = await pumpSample(tester);
        expect(context.colors, same(colors));
        expect(context.shadows, same(shadows));
        expect(context.categoryColors, isNotNull);
      });
    });
  }

  test('theme mode defaults to system and can be changed', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(appThemeModeProvider), ThemeMode.system);

    container.read(appThemeModeProvider.notifier).mode = ThemeMode.dark;
    expect(container.read(appThemeModeProvider), ThemeMode.dark);
  });

  testWidgets('app follows the theme mode preference', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    Brightness brightness() =>
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

    container.read(appThemeModeProvider.notifier).mode = ThemeMode.dark;
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);

    container.read(appThemeModeProvider.notifier).mode = ThemeMode.light;
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);
  });
}
