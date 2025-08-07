import 'dart:io';

import 'package:flutter/widgets.dart';

import 'runtime_platform.dart';

class PlatformFileMananger {
  static void highlightFileInFolder(String filePath) {
    if (RuntimePlatform.isWindows) {
      Process.run('explorer', ['/select,', filePath]);
    } else if (RuntimePlatform.isMacOS) {
      Process.run('open', ['-R', filePath]);
    } else if (RuntimePlatform.isLinux) {
      Process.run('xdg-open', [filePath]);
    } else {
      debugPrint('Unsupported platform');
    }
  }

  static void openFolder(String folderPath) {
    if (RuntimePlatform.isWindows) {
      Process.run('explorer', [folderPath]);
    } else if (RuntimePlatform.isMacOS) {
      Process.run('open', [folderPath]);
    } else if (RuntimePlatform.isLinux) {
      Process.run('xdg-open', [folderPath]);
    } else {
      debugPrint('Unsupported platform');
    }
  }
}
