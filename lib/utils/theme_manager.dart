import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'logger.dart';
import 'prefs.dart';

class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  final Completer<void> _completer = Completer<void>();
  bool isDark = true;

  // Private constructor
  ThemeManager._internal();

  // Singleton accessor
  factory ThemeManager() {
    return _instance;
  }

  Future<void> init() async {
    logger.d("starting: ThemeManager.init");
    update();
    _completer.complete(); // Signal that initialization is complete
    logger.d("starting: ThemeManager.init");
  }

  void update({bool notify = false}) {
    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    isDark = prefs.getBool('app.brightness.followSystem')!
        ? dispatcher.platformBrightness == Brightness.dark
        : prefs.getBool('app.brightness.dark')!;

    /// no need to change here as already defined in didChangeDependencies
    // Window.setEffect(
    //   effect: WindowEffect.mica,
    //   dark: isDark,
    // );
    if (notify){
      notifyListeners();
    }
  }
}

final themeManager = ThemeManager();
