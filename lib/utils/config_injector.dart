import 'package:shared_preferences/shared_preferences.dart';

import '../models/log_level.dart';

Future<Map<String, dynamic>> getInjectedConfig(Map<String, dynamic> cfg) async {
  final prefs = await SharedPreferences.getInstance();

  final injectLog = prefs.getBool('injectLog') ?? true;
  final logLevel = LogLevel.values[prefs.getInt('logLevel') ?? LogLevel.warning.index];
  final injectApi = prefs.getBool('injectApi') ?? true;
  final apiPort = prefs.getInt('apiPort') ?? 15490;

  if (injectLog) {
    cfg["log"] = {"loglevel": logLevel.name};
  }

  if (injectApi) {
    cfg["api"] = {
      "tag": "ot_api",
      "services": ["HandlerService", "StatsService"]
    };

    cfg["inbounds"] += [
      {
        "listen": "127.0.0.1",
        "port": apiPort,
        "protocol": "dokodemo-door",
        "settings": {"address": "127.0.0.1"},
        "tag": "in_api"
      }
    ];

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
