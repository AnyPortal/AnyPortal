import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart' if (dart.library.html) 'path_provider/web.dart';

import 'logger.dart';
import 'platform_elevation.dart';

class GlobalManager {
  late Directory applicationDocumentsDirectory;
  late Directory applicationSupportDirectory;
  late bool isElevated;

  Future<void> init() async {
    logger.d("starting: GlobalManager.init");
    await Future.wait([
      updateAapplicationDocumentsDirectory(),
      updateApplicationsupportDirectory(),
      updateIsElevated(),
    ]);
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: GlobalManager.init");
  }

  Future<void> updateAapplicationDocumentsDirectory() async {
    applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
  }

  Future<void> updateApplicationsupportDirectory() async {
    applicationSupportDirectory = await getApplicationSupportDirectory();
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
