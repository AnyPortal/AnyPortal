import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import '../main.dart';
import 'prefs.dart';

class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  ThemeManager._internal();

  // Singleton accessor
  factory ThemeManager() {
    return _instance;
  }

  Future<void> init() async {
    _completer.complete(); // Signal that initialization is complete
  }

  void updateBrightness() {
    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    final isDark = prefs.getBool('app.brightness.followSystem')!
        ? dispatcher.platformBrightness == Brightness.dark
        : prefs.getBool('app.brightness.dark')!;
    Window.setEffect(
      effect: WindowEffect.mica,
      dark: isDark,
    );

    darkNotifier.value = isDark;
  }
}

final themeManager = ThemeManager();
