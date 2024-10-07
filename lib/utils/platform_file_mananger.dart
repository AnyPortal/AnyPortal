import 'dart:io';
import 'package:flutter/material.dart';

class PlatformFileMananger {
  static void highlightFileInFolder(String filePath) {
    if (Platform.isWindows) {
      Process.run('explorer', ['/select,', filePath]);
    } else if (Platform.isMacOS) {
      Process.run('open', ['-R', filePath]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [filePath]);
    } else {
      debugPrint('Unsupported platform');
    }
  }

  static void openFolder(String folderPath) {
    if (Platform.isWindows) {
      Process.run('explorer', [folderPath]);
    } else if (Platform.isMacOS) {
      Process.run('open', [folderPath]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [folderPath]);
    } else {
      debugPrint('Unsupported platform');
    }
  }
}
