import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../models/log_level.dart';
import '../../../models/send_through_binding_stratagy.dart';
import '../../connectivity_manager.dart';
import '../../global.dart';
import '../../prefs.dart';
import '../base/config_injector.dart';

class ConfigInjectorSingBox extends ConfigInjectorBase {
  @override
  Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
    Map<String, dynamic> cfg = jsonDecode(cfgStr) as Map<String, dynamic>;
    final injectLog = prefs.getBool('inject.log')!;
    final injectApi = prefs.getBool('inject.api')!;
    final logLevel = LogLevel.values[prefs.getInt('inject.log.level')!];
    final serverAddress = prefs.getString('app.server.address')!;
    final apiPort = prefs.getInt('inject.api.port')!;
    final injectSocks = prefs.getBool('inject.socks')!;
    final socksPort = prefs.getInt('app.socks.port')!;
    final injectHttp = prefs.getBool('inject.http')!;
    final httpPort = prefs.getInt('app.http.port')!;
    final injectSendThrough = prefs.getBool('inject.sendThrough')!;
    final sendThroughBindingStratagy = SendThroughBindingStratagy
        .values[prefs.getInt('inject.sendThrough.bindingStratagy')!];

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
      cfg["experimental"]["clash_api"] = {
        "external_controller": "$serverAddress:$apiPort",
      };
      // cfg["experimental"]["v2ray_api"] = {
      //   "listen": "$serverAddress:$apiPort",
      //   "stats": {
      //     "enabled": true,
      //     "outbounds": outboundTags,
      //   }
      // };
    }

    if (!cfg.containsKey("inbounds")) {
      cfg["inbounds"] = [];
    }

    if (injectHttp) {
      (cfg["inbounds"] as List).insert(0, {
        "listen_port": httpPort,
        "tag": "anyportal_in_http",
        "type": "http"
      });
    }
    if (injectSocks) {
      (cfg["inbounds"] as List).insert(0, {
        "listen_port": socksPort,
        "tag": "anyportal_in_mixed",
        "type": "mixed"
      });
    }

    if (!cfg.containsKey("outbounds")) {
      cfg["outbounds"] = [];
    }
    if (injectSendThrough) {
      String? interfaceName;
      String? inet4BindAddress;
      String? inet6BindAddress;
      switch (sendThroughBindingStratagy) {
        case SendThroughBindingStratagy.internet:
          final effectiveNetInterface =
              await ConnectivityManager().getEffectiveNetInterface();
          interfaceName = effectiveNetInterface?.name;
        case SendThroughBindingStratagy.ip:
          final ip = prefs.getString('inject.sendThrough.bindingIp')!;
          if (ip.contains(":")) {
            inet6BindAddress = ip;
          } else {
            inet4BindAddress = ip;
          }
        case SendThroughBindingStratagy.interface:
          interfaceName =
              prefs.getString('inject.sendThrough.bindingInterface')!;
      }
      for (var outbound in cfg["outbounds"]) {
        switch (sendThroughBindingStratagy) {
          case SendThroughBindingStratagy.internet:
          case SendThroughBindingStratagy.interface:
            outbound["bind_interface"] = interfaceName;
          case SendThroughBindingStratagy.ip:
            outbound["inet4_bind_address"] = inet4BindAddress;
            outbound["inet6_bind_address"] = inet6BindAddress;
        }
      }
    }

    return jsonEncode(cfg);
  }

  @override
  Future<String> getInjectedConfigPing(
      String cfgStr, String coreCfgFmt, int socksPort) async {
    final cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

    if (!cfg.containsKey("inbounds")) {
      cfg["inbounds"] = [];
    }
    final inbounds = (cfg["inbounds"] as List).cast<Map<String, dynamic>>();

    for (final inbound in inbounds) {
      if (inbound.containsKey("listen_port")) {
        inbound["listen"] = "127.0.0.1";
        inbound.remove("listen_port");
      }

      if (inbound.containsKey("type") &&
          inbound["type"] == "tun" &&
          inbound.containsKey("tag")) {
        inbound.clear();
        inbound.addAll({
          "listen": "127.0.0.1",
          "type": "mixed",
          "tag": inbound["tag"],
        });
      }
    }

    inbounds.insert(0, {
      "listen": "127.0.0.1",
      "listen_port": socksPort,
      "type": "mixed",
    });

    return jsonEncode(cfg);
  }
}
