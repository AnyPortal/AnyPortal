import 'dart:io';

import 'package:flutter/foundation.dart';

class PlatformManager {
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isLinux => !kIsWeb && Platform.isLinux;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

  static String get operatingSystem =>
      !kIsWeb ? Platform.operatingSystem : 'web';
}

final platform = PlatformManager();
