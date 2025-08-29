import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../global.dart';
import '../../prefs.dart';
import '../base/config_injector.dart';

class ConfigInjectorNaive extends ConfigInjectorBase {
  @override
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
    final cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

    final injectLog = prefs.getBool('inject.log')!;
    final serverAddress = prefs.getString('app.server.address')!;
    final injectSocks = prefs.getBool('inject.socks')!;
    final socksPort = prefs.getInt('app.socks.port')!;
    final injectHttp = prefs.getBool('inject.http')!;
    final httpPort = prefs.getInt('app.http.port')!;

    if (injectLog) {
      final pathLogErr = File(
        p.join(global.applicationSupportDirectory.path, 'log', 'core.log'),
      ).absolute.path;
      cfg["log"] = pathLogErr;
      // cfg["log-net-log"] = pathLogErr;
    }

    if (!cfg.containsKey("listen")) {
      cfg["listen"] = [];
    }

    if (cfg["listen"] is String) {
      cfg["listen"] = [cfg["listen"]];
    }

    final listen = cfg["listen"] as List;

    if (injectSocks) {
      listen.add("socks://$serverAddress:$socksPort");
    }

    if (injectHttp) {
      listen.add("http://$serverAddress:$httpPort");
    }

    return jsonEncode(cfg);
  }

  @override
  Future<String> getInjectedConfigPing(
    String cfgStr,
    String coreCfgFmt,
    int socksPort,
  ) async {
    final cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

    final serverAddress = prefs.getString('app.server.address')!;

    cfg["listen"] = "socks://$serverAddress:$socksPort";

    return jsonEncode(cfg);
  }
}
