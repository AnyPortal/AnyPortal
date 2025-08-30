import 'dart:async';
import 'dart:io';

import 'package:anyportal/utils/runtime_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'global.dart';
import 'logger.dart';
import 'prefs.dart';

class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  final Completer<void> _completer = Completer<void>();
  bool isDark = true;
  bool platformBrightnessIsDark = true;

  // Private constructor
  ThemeManager._internal();

  // Singleton accessor
  factory ThemeManager() {
    return _instance;
  }

  Future<void> init() async {
    logger.d("starting: ThemeManager.init");
    await update();
    _completer.complete(); // Signal that initialization is complete
    logger.d("starting: ThemeManager.init");
  }

  Future<void> update({bool notify = false}) async {
    if (RuntimePlatform.isMacOS && global.isElevated) {
      final sudoUser = Platform.environment["SUDO_USER"];
      if (sudoUser == null) {
        logger.w("failed to get SUDO_USER");
        platformBrightnessIsDark = getPlatformBrightness() == Brightness.dark;
      } else {
        // logger.d("SUDO_USER: $sudoUser");
        final result = await Process.run(
          'sudo',
          [
            '-u',
            sudoUser,
            'defaults',
            'read',
            '-g',
            'AppleInterfaceStyle',
          ],
        );
        // logger.d("platformBrightness: ${result.stdout}");
        platformBrightnessIsDark = result.stdout == 'Dark\n';
      }
    } else {
      platformBrightnessIsDark = getPlatformBrightness() == Brightness.dark;
    }

    isDark = prefs.getBool('app.brightness.followSystem')!
        ? platformBrightnessIsDark
        : prefs.getBool('app.brightness.dark')!;

    /// no need to change here as already defined in didChangeDependencies
    // Window.setEffect(
    //   effect: WindowEffect.mica,
    //   dark: isDark,
    // );
    if (notify) {
      notifyListeners();
    }
  }

  Brightness getPlatformBrightness() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness;
  }
}

final themeManager = ThemeManager();
