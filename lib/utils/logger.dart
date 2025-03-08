import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'logger/filter.dart';
import 'logger/printer.dart';

class LoggerManager {
  late Logger logger;

  Level getLevelByName(String? name) {
    return Level.values.firstWhere(
      (level) => level.name == name,
      orElse: () => Level.off,
    );
  }

  Future<void> init(
    {String? logLevelName}
  ) async {
    final logLevel = getLevelByName(logLevelName);

    final applicationSupportDirectory = await getApplicationSupportDirectory();
    final file = File(
      p.join(
        applicationSupportDirectory.path,
        "log",
        "app.log",
      ),
    );
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
    await file.create(recursive: true);
    file.create(recursive: true);
    logger = Logger(
      printer: CustomLogPrinter(),
      output: MultiOutput(
        [
          ConsoleOutput(),
          FileOutput(
            file: file,
          ),
        ],
      ),
      level: kDebugMode ? Level.all : logLevel,
      filter: CustomFilter()
    );
    _completer.complete(); // Signal that initialization is complete
    logger.d("finished: LoggerManager.init");
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
