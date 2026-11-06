import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// The stored Theme setting (S33) as a [ThemeMode]. System until the
/// settings have loaded. Change it with `PreferencesRepository.update`.
@Riverpod(keepAlive: true)
ThemeMode appThemeMode(Ref ref) =>
    switch (ref.watch(preferencesProvider).value?.theme) {
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
      AppTheme.system || null => ThemeMode.system,
    };
