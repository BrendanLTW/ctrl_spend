import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_shadows.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme() => _build(
  Brightness.light,
  AppColors.light,
  CategoryColors.light,
  AppShadows.light,
);

ThemeData buildDarkTheme() => _build(
  Brightness.dark,
  AppColors.dark,
  CategoryColors.dark,
  AppShadows.dark,
);

ThemeData _build(
  Brightness brightness,
  AppColors c,
  CategoryColors categories,
  AppShadows shadows,
) {
  const t = AppTypography();
  return ThemeData(
    brightness: brightness,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.ink,
      onPrimary: c.onInk,
      secondary: c.ink,
      onSecondary: c.onInk,
      error: c.negative,
      onError: c.onInk,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.muted,
      surfaceContainerHighest: c.raised,
      outline: c.control,
      outlineVariant: c.divider,
    ),
    scaffoldBackgroundColor: c.ground,
    dividerColor: c.divider,
    textTheme: TextTheme(
      displayLarge: t.display,
      headlineMedium: t.pageTitle,
      titleLarge: t.header,
      titleMedium: t.rowTitle,
      bodyLarge: t.body,
      bodyMedium: t.body,
      bodySmall: t.caption,
      labelLarge: t.button,
      labelMedium: t.label,
      labelSmall: t.labelSm,
    ).apply(bodyColor: c.ink, displayColor: c.ink),
    extensions: [c, categories, shadows],
  );
}
