import 'dart:io';
import 'package:flutter/material.dart';

void openFileInFileManager(String filePath) {
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