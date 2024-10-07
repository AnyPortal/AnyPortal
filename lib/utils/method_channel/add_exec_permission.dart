import '../logger.dart';

import 'package:flutter/services.dart';

class FilePermission {
  static const platform = MethodChannel('com.github.anyportal.anyportal');

  static Future<void> addExecutablePermission(String filePath) async {
    try {
      await platform.invokeMethod('addExecutablePermission', {'filePath': filePath});
    } on PlatformException catch (e) {
      logger.d("Failed to change file permission: '${e.message}'.");
    }
  }
}