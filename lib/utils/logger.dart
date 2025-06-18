import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'
    if (dart.library.html) 'path_provider/web.dart';

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

  Future<void> init({
    String? logLevelName,
    bool overrideExisting=false,
  }) async {
    final logLevel = getLevelByName(logLevelName);

    if (kIsWeb) {
      logger = Logger(
          printer: CustomLogPrinter(),
          output: MultiOutput(
            [
              ConsoleOutput(),
            ],
          ),
          level: kDebugMode ? Level.all : logLevel,
          filter: CustomFilter());
      _completer.complete();
      logger.d("finished: LoggerManager.init");
      return;
    }

    final applicationSupportDirectory = await getApplicationSupportDirectory();
    final file = File(
      p.join(
        applicationSupportDirectory.path,
        "log",
        "app.log",
      ),
    );
    await file.create(recursive: true);
    file.create(recursive: true);
    logger = Logger(
        printer: CustomLogPrinter(),
        output: MultiOutput(
          [
            ConsoleOutput(),
            FileOutput(
              file: file,
              overrideExisting: overrideExisting,
            ),
          ],
        ),
        level: kDebugMode ? Level.all : logLevel,
        filter: CustomFilter());
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
