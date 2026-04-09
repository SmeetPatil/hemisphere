import 'package:flutter/material.dart';

class DevModeProvider extends ValueNotifier<bool> {
  DevModeProvider._() : super(false);

  static final DevModeProvider instance = DevModeProvider._();

  bool get isDevMode => value;

  void setDevMode(bool mode) {
    value = mode;
  }

  void toggleDevMode() {
    value = !value;
  }
}
