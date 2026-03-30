<<<<<<< HEAD
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
=======
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
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
