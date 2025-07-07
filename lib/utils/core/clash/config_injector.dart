import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../../../models/log_level.dart';
import '../../global.dart';
import '../../prefs.dart';
import '../base/config_injector.dart';

class ConfigInjectorClash extends ConfigInjectorBase {
  @override
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
    Map<String, dynamic> cfg = {};
    switch (coreCfgFmt) {
      case "json":
        cfg = jsonDecode(cfgStr) as Map<String, dynamic>;
        break;
      case "yaml":
      case _:
        cfg = loadYaml(cfgStr) as Map<String, dynamic>;
        break;
    }

    final injectLog = prefs.getBool('inject.log')!;
    final injectApi = prefs.getBool('inject.api')!;
    final logLevel = LogLevel.values[prefs.getInt('inject.log.level')!];
    final serverAddress = prefs.getString('app.server.address')!;
    final apiPort = prefs.getInt('inject.api.port')!;
    final injectSocks = prefs.getBool('inject.socks')!;
    final socksPort = prefs.getInt('app.socks.port')!;

    if (injectLog) {
      final pathLog = File(p.join(
        global.applicationSupportDirectory.path,
        'log',
        'core.log',
      )).absolute.path;
      cfg["log-level"] = logLevel.name;
      cfg["log-file"] = pathLog;
    }

    if (injectApi) {
      cfg["external-controller"] = "$serverAddress:$apiPort";
      // cfg["secret"] ??= "";
    }

    if (injectSocks) {
      cfg["mixed-port"] = socksPort;
    }

    switch (coreCfgFmt) {
      case "json":
        return jsonEncode(cfg);
      case "yaml":
      case _:
        return YamlWriter().write(cfg);
    }
  }
}
