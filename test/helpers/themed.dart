import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Light and dark, with the colours each should produce.
final List<
  ({String name, ThemeData theme, AppColors colors, CategoryColors categories})
>
themes = [
  (
    name: 'light',
    theme: buildLightTheme(),
    colors: AppColors.light,
    categories: CategoryColors.light,
  ),
  (
    name: 'dark',
    theme: buildDarkTheme(),
    colors: AppColors.dark,
    categories: CategoryColors.dark,
  ),
];

/// Pumps [child] on a ground-coloured screen in [theme].
Future<void> pumpThemed(WidgetTester tester, ThemeData theme, Widget child) =>
    tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    );
