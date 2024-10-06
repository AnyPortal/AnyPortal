
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class GlobalManager {
  late Directory applicationDocumentsDirectory;
  late Directory applicationSupportDirectory;

  Future<void> init() async {
    await Future.wait([
      setAapplicationDocumentsDirectory(),
      setApplicationsupportDirectory(),
    ]);
    _completer.complete(); // Signal that initialization is complete
  }

  Future<void> setAapplicationDocumentsDirectory() async {
    applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
  }

  Future<void> setApplicationsupportDirectory() async {
    applicationSupportDirectory = await getApplicationSupportDirectory();
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
