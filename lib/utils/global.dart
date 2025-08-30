import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart'
    if (dart.library.html) 'path_provider/web.dart';

import 'package:anyportal/utils/runtime_platform.dart';

import 'logger.dart';
import 'platform_elevation.dart';

class GlobalManager {
  late Directory applicationDocumentsDirectory;
  late Directory applicationSupportDirectory;
  late Directory applicationCacheDirectory;
  bool isElevated = false;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> init() async {
    logger.d("starting: GlobalManager.init");
    if (!RuntimePlatform.isWeb) {
      await Future.wait([
        updateAapplicationDocumentsDirectory(),
        updateApplicationSupportDirectory(),
        updateApplicationCacheDirectory(),
        updateIsElevated(),
      ]);
    } else {
      applicationDocumentsDirectory = Directory("");
      applicationSupportDirectory = Directory("");
      applicationCacheDirectory = Directory("");
    }
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: GlobalManager.init");
  }

  Future<void> updateAapplicationDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    applicationDocumentsDirectory = Directory(await directory.resolveSymbolicLinks());
  }

  Future<void> updateApplicationSupportDirectory() async {
    final directory = await getApplicationSupportDirectory();

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    applicationSupportDirectory = Directory(await directory.resolveSymbolicLinks());
  }

  Future<void> updateApplicationCacheDirectory() async {
    final directory = await getApplicationCacheDirectory();

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    applicationCacheDirectory = Directory(await directory.resolveSymbolicLinks());
  }

  Future<void> updateIsElevated() async {
    isElevated = await PlatformElevation.isElevated();
  }

  static final GlobalManager _instance = GlobalManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  GlobalManager._internal();

  // Singleton accessor
  factory GlobalManager() {
    return _instance;
  }
}

final global = GlobalManager();
