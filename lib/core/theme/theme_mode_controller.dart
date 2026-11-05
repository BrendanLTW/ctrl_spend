import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// The Theme preference: Light, Dark or System.
// shortcut: in-memory, resets on restart; back it with the stored setting
// when the settings repository lands.
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  ThemeMode get mode => state;
  set mode(ThemeMode value) => state = value;
}
