import 'dart:io';

import 'package:flutter/material.dart';

import 'platform.dart';

class PlatformFileMananger {
  static void highlightFileInFolder(String filePath) {
    if (platform.isWindows) {
      Process.run('explorer', ['/select,', filePath]);
    } else if (platform.isMacOS) {
      Process.run('open', ['-R', filePath]);
    } else if (platform.isLinux) {
      Process.run('xdg-open', [filePath]);
    } else {
      debugPrint('Unsupported platform');
    }
  }

  static void openFolder(String folderPath) {
    if (platform.isWindows) {
      Process.run('explorer', [folderPath]);
    } else if (platform.isMacOS) {
      Process.run('open', [folderPath]);
    } else if (platform.isLinux) {
      Process.run('xdg-open', [folderPath]);
    } else {
      debugPrint('Unsupported platform');
    }
  }
}
