import 'dart:io';

import 'package:fv2ray/utils/get_local_ip.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/log_level.dart';
import '../models/send_through_binding_stratagy.dart';
import 'prefs.dart';

Future<Map<String, dynamic>> getInjectedConfig(Map<String, dynamic> cfg) async {
  final injectLog = prefs.getBool('inject.log') ?? true;
  final injectApi = prefs.getBool('inject.api') ?? true;
  final injectSendThrough = prefs.getBool('inject.sendThrough') ?? false;
  final logLevel =
      LogLevel.values[prefs.getInt('inject.log.level') ?? LogLevel.warning.index];
  final apiPort = prefs.getInt('inject.api.port') ?? 15490;
  final injectSocks = prefs.getBool('inject.socks')!;
  final injectSocksPort = prefs.getInt('inject.socks.port')!;

  final sendThroughBindingStratagy = SendThroughBindingStratagy.values[
      prefs.getInt('inject.sendThrough.bindingStratagy') ??
          SendThroughBindingStratagy.ip.index];
  String sendThrough = "0.0.0.0";
  switch (sendThroughBindingStratagy) {
    // case SendThroughBindingStratagy.internet:
    //   autoDetectedSendThrough = await getIPAddr();
    //   if (autoDetectedSendThrough != null){
    //     sendThrough = autoDetectedSendThrough;
    //   }
    case SendThroughBindingStratagy.ip:
      sendThrough = prefs.getString('inject.sendThrough.bindingIp') ?? "0.0.0.0";
    case SendThroughBindingStratagy.interface:
      final bindingInterface = prefs.getString('inject.sendThrough.bindingInterface') ?? "eth0";
      final ip = await getIPv4OfInterface(bindingInterface);
      if (ip == null) {
        throw Exception('ip not found for binding interface $bindingInterface');
      }
      sendThrough = ip;
  }

  if (injectLog) {
    final folder = await getApplicationDocumentsDirectory();
    final pathLogErr =
        File(p.join(folder.path, 'fv2ray', 'core.log')).absolute.path;
    cfg["log"] = {
      "loglevel": logLevel.name,
      "error": pathLogErr,
      "access": pathLogErr,
    };
  }

  if (injectApi) {
    cfg["api"] = {
      "tag": "ot_api",
      "services": ["HandlerService", "StatsService"]
    };

    if (!cfg.containsKey("inbounds")){
      cfg["inbounds"] = [];
    }

    cfg["inbounds"] += [
      {
        "listen": "127.0.0.1",
        "port": apiPort,
        "protocol": "dokodemo-door",
        "settings": {"address": "127.0.0.1"},
        "tag": "in_api"
      }
    ];

    if (!cfg.containsKey("routing")){
      cfg["routing"] = {"rules": []};
    }

    if (!cfg["routing"].containsKey("rules")){
      cfg["routing"]["rules"] = [];
    }

    cfg["routing"]["rules"].insert(0, {
      "type": "field",
      "inboundTag": ["in_api"],
      "outboundTag": "ot_api"
    });

    cfg["policy"] = {
      "levels": {
        "0": {"statsUserUplink": true, "statsUserDownlink": true}
      },
      "system": {
        "statsInboundUplink": true,
        "statsInboundDownlink": true,
        "statsOutboundUplink": true,
        "statsOutboundDownlink": true
      }
    };

    cfg["stats"] = {};
  }

  if (injectSocks) {
    cfg["inbounds"].insert(0, {
      "listen": "127.0.0.1",
      "port": injectSocksPort,
      "protocol": "socks",
      "settings": {
        "udp": true
      },
      "sniffing": {
        "enabled": true
      },
      "tag": "fv2ray_in_socks"
    });
  }

  if (injectSendThrough) {
    for (var outbound in cfg["outbounds"]) {
      outbound["sendThrough"] = sendThrough;
    }
  }

  // cfg["services"] = {
  //   "tun": {
  //     "name": "tun0",
  //     "mtu": 1500,
  //     "tag": "tun",
  //     "ips": [{ "ip": [198, 18, 0, 0], "prefix": 15 }],
  //     "routes": [
  //        { "ip": [0, 0, 0, 0], "prefix": 0 }
  //        // , { "ip": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "prefix": 0 }
  //     ],
  //     "enablePromiscuousMode": true,
  //     "enableSpoofing": true
  //   }
  // };

  return cfg;
}
