import 'dart:developer';

import 'package:flutter/services.dart';

class FilePermission {
  static const platform = MethodChannel('com.github.fv2ray.fv2ray');

  static Future<void> addExecutablePermission(String filePath) async {
    try {
      await platform.invokeMethod('addExecutablePermission', {'filePath': filePath});
    } on PlatformException catch (e) {
      log("Failed to change file permission: '${e.message}'.");
    }
  }
}