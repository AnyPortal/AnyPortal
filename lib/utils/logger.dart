import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import 'global.dart';

class LoggerManager {
  late Logger logger;

  void init() {
    logger = Logger(
      // printer: PrettyPrinter(),
      output: MultiOutput(
        [
          ConsoleOutput(),
          FileOutput(
              file: File(p.join(
                  global.applicationSupportDirectory.path, "log", "app.log"))),
        ],
      ),
      level: kDebugMode ? Level.all : Level.warning,
    );
    _completer.complete(); // Signal that initialization is complete
  }

  static final LoggerManager _instance = LoggerManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  LoggerManager._internal();

  // Singleton accessor
  factory LoggerManager() {
    return _instance;
  }
}

final logger = LoggerManager().logger;
