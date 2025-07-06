import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../models/log_level.dart';
import '../../global.dart';
import '../../prefs.dart';
import '../base/config_injector.dart';

class ConfigInjectorSingBox extends ConfigInjectorBase {
  @override
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
    Map<String, dynamic> cfg = jsonDecode(cfgStr) as Map<String, dynamic>;
    final injectLog = prefs.getBool('inject.log')!;
    final injectApi = prefs.getBool('inject.api')!;
    // final injectSendThrough = prefs.getBool('inject.sendThrough')!;
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
      cfg["log"] = {
        "disabled": false,
        "level": logLevel.name,
        "timestamp": true,
        "output": pathLog
      };
    }

    if (injectApi) {
      if (!cfg.containsKey("experimental")) {
        cfg["experimental"] = {};
      }
      final outboundTags = [];
      for (Map<String, dynamic> outbound in cfg["outbounds"]) {
        if (outbound.containsKey("tag")) {
          outboundTags.add(outbound["tag"]);
        }
      }
      cfg["experimental"]["v2ray_api"] = {
        "listen": "$serverAddress:$apiPort",
        "stats": {
          "enabled": true,
          "outbounds": outboundTags,
        }
      };
    }

    if (!cfg.containsKey("inbounds")) {
      cfg["inbounds"] = [];
    }
    if (injectSocks) {
      cfg["inbounds"].add({
        "listen_port": socksPort,
        "tag": "anyportal_in_socks",
        "type": "mixed"
      });
    }

    return jsonEncode(cfg);
  }
}
