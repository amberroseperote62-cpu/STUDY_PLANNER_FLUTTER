import 'package:flutter/material.dart';

/// Holds the app's theme mode. MaterialApp listens to [mode], so changing it
/// from anywhere (e.g. the Profile screen switch) re-themes the whole app.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static void setDark(bool dark) {
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }
}