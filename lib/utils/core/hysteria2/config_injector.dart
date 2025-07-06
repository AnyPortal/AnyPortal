import 'dart:convert';

import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import 'package:anyportal/utils/core/base/config_injector.dart';
import 'package:anyportal/utils/core/base/plugin.dart';

import '../../../models/log_level.dart';
import '../../prefs.dart';

class ConfigInjectorHysteria2 extends ConfigInjectorBase {
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
    // final injectSendThrough = prefs.getBool('inject.sendThrough')!;
    final logLevel = LogLevel.values[prefs.getInt('inject.log.level')!];
    final serverAddress = prefs.getString('app.server.address')!;
    final apiPort = prefs.getInt('inject.api.port')!;
    final injectSocks = prefs.getBool('inject.socks')!;
    final socksPort = prefs.getInt('app.socks.port')!;

    if (injectLog) {
      String logLevelStr = "";
      switch (logLevel) {
        case LogLevel.debug:
          logLevelStr = "debug";
        case LogLevel.warning:
          logLevelStr = "warn";
        case LogLevel.error:
          logLevelStr = "error";
        case LogLevel.info:
        case _:
          logLevelStr = "info";
      }
      CorePluginManager.instances["hysteria2"]!
          .environment["HYSTERIA_LOG_LEVEL"] = logLevelStr;
    }

    if (injectApi) {
      cfg["trafficStats"] = {"listen": "$serverAddress:$apiPort"};
    }

    if (injectSocks) {
      cfg["socks"] = {
        "listen": "$serverAddress:$socksPort",
        "disableUDP": false
      };
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
