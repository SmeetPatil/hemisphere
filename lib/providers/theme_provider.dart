import 'package:flutter/material.dart';

class ThemeProvider extends ValueNotifier<ThemeMode> {
  ThemeProvider._() : super(ThemeMode.dark);

  static final ThemeProvider instance = ThemeProvider._();

  bool get isDark => value == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    value = mode;
  }

  void toggleTheme() {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}
