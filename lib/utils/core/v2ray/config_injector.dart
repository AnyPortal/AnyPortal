import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart' as p;

import '../../../extensions/localization.dart';
import '../../../models/log_level.dart';
import '../../../models/send_through_binding_stratagy.dart';
import '../../get_local_ip.dart';
import '../../global.dart';
import '../../prefs.dart';
import '../../runtime_platform.dart';
import '../../show_snack_bar_now.dart';
import '../../with_context.dart';

Future<String> getInjectedConfig(String cfgStr, String coreCfgFmt) async {
  Map<String, dynamic> cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

  final injectLog = prefs.getBool('inject.log')!;
  final injectApi = prefs.getBool('inject.api')!;
  final injectSendThrough = prefs.getBool('inject.sendThrough')!;
  final logLevel = LogLevel.values[prefs.getInt('inject.log.level')!];
  final serverAddress = prefs.getString('app.server.address')!;
  final apiPort = prefs.getInt('inject.api.port')!;
  final injectSocks = prefs.getBool('inject.socks')!;
  final socksPort = prefs.getInt('app.socks.port')!;

  final sendThroughBindingStratagy = SendThroughBindingStratagy
      .values[prefs.getInt('inject.sendThrough.bindingStratagy')!];
  String sendThrough = "0.0.0.0";
  if (injectSendThrough) {
    switch (sendThroughBindingStratagy) {
      // case SendThroughBindingStratagy.internet:
      //   final autoDetectedSendThrough = await getIPAddr();
      //   if (autoDetectedSendThrough != null){
      //     sendThrough = autoDetectedSendThrough;
      //   }
      case SendThroughBindingStratagy.ip:
        sendThrough = prefs.getString('inject.sendThrough.bindingIp')!;
      case SendThroughBindingStratagy.interface:
        final bindingInterface =
            prefs.getString('inject.sendThrough.bindingInterface')!;
        final ip = await getIPv4OfInterface(bindingInterface);
        if (ip == null) {
          withContext((context) {
            showSnackBarNow(
                context,
                Text(context.loc
                    .ip_not_found_for_binding_interface_binding_interface(
                        bindingInterface)));
          });
          throw Exception(
              'IP not found for binding interface: $bindingInterface');
        }
        sendThrough = ip;
    }
  }

  if (!RuntimePlatform.isWeb && injectLog) {
    final pathLogErr = File(p.join(
      global.applicationSupportDirectory.path,
      'log',
      'core.log',
    )).absolute.path;
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

    if (!cfg.containsKey("inbounds")) {
      cfg["inbounds"] = [];
    }

    cfg["inbounds"] += [
      {
        "listen": serverAddress,
        "port": apiPort,
        "protocol": "dokodemo-door",
        "settings": {"address": serverAddress},
        "tag": "in_api"
      }
    ];

    if (!cfg.containsKey("routing")) {
      cfg["routing"] = {"rules": []};
    }

    if (!cfg["routing"].containsKey("rules")) {
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
      "port": socksPort,
      "protocol": "socks",
      "settings": {"udp": true},
      "sniffing": {"enabled": true},
      "tag": "anyportal_in_socks"
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

  return jsonEncode(cfg);
}
