import 'dart:async';

import 'package:args/args.dart';

class ArgParserManager {
  late ArgParser parser;
  late ArgResults cliArg;

  Future<void> init(List<String> args) async {
    parser = ArgParser();
    parser.addFlag('minimized', negatable: false);
    parser.addOption('log-level');
    cliArg = parser.parse(args);
    _completer.complete();
  }

  static final ArgParserManager _instance = ArgParserManager._internal();
  final Completer<void> _completer = Completer<void>();

  // Private constructor
  ArgParserManager._internal();

  // Singleton accessor
  factory ArgParserManager() {
    return _instance;
  }
}

final cliArg = ArgParserManager().cliArg;
