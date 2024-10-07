
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'platform_elevation.dart';

class GlobalManager {
  late Directory applicationDocumentsDirectory;
  late Directory applicationSupportDirectory;
  late bool isElevated;

  Future<void> init() async {
    await Future.wait([
      setAapplicationDocumentsDirectory(),
      setApplicationsupportDirectory(),
      setIsElevated(),
    ]);
    _completer.complete(); // Signal that initialization is complete
  }

  Future<void> setAapplicationDocumentsDirectory() async {
    applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
  }

  Future<void> setApplicationsupportDirectory() async {
    applicationSupportDirectory = await getApplicationSupportDirectory();
  }

  Future<void> setIsElevated() async {
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
