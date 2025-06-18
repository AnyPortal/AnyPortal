import 'dart:io';

import 'package:flutter/foundation.dart';

class RuntimePlatform {
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
  static bool get isWeb => kIsWeb;

  static String get operatingSystem =>
      !kIsWeb ? Platform.operatingSystem : 'web';
}
