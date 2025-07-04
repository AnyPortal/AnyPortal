import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../models/log_level.dart';
import '../../global.dart';
import '../../prefs.dart';
import '../../runtime_platform.dart';
import '../../vpn_manager.dart';

Future<Map<String, dynamic>> getInjectedConfigTunSingBox(
    Map<String, dynamic> cfg) async {
  final injectLog = prefs.getBool('tun.inject.log')!;
  final logLevel = LogLevel.values[prefs.getInt('tun.inject.log.level')!];
  final injectSocks = prefs.getBool('tun.inject.socks')!;
  final injectHttp = prefs.getBool('tun.inject.http')!;
  String injectServerAddress = prefs.getString('app.server.address')!;
  if (injectServerAddress == "0.0.0.0") {
    injectServerAddress = "127.0.0.1";
  }
  final injectSocksPort = prefs.getInt('app.socks.port')!;
  final injectHttpPort = prefs.getInt('app.http.port')!;
  final injectExcludeCore = prefs.getBool('tun.inject.excludeCorePath')!;
  final corePath = vPNMan.corePath;

  if (injectLog) {
    final pathLog = File(p.join(
      global.applicationSupportDirectory.path,
      'log',
      'tun.sing_box.log',
    )).absolute.path;
    cfg["log"] = {
      "disabled": false,
      "level": logLevel.name,
      "timestamp": true,
      "output": pathLog
    };
  }

  final outbounds = cfg["outbounds"] as List<dynamic>;
  if (injectHttp) {
    outbounds.insert(0, {
      "type": "http",
      "tag": "ot_http",
      "server": injectServerAddress,
      "server_port": injectHttpPort
    });
  }
  if (injectSocks) {
    outbounds.insert(0, {
      "type": "socks",
      "tag": "ot_socks",
      "server": injectServerAddress,
      "server_port": injectSocksPort
    });
  }

  final route = cfg["route"] as Map<String, dynamic>;
  final rules = route["rules"] as List<dynamic>;
  if (injectExcludeCore) {
    if (corePath != null) {
      rules.insert(0, {
        "process_path": [corePath],
        "outbound": "ot_direct",
      });

      /// not working
      // cfg["dns"]["rules"].insert(0, {
      //   "process_path": [corePath],
      //   "server": "dn_auto",
      // });
    }
  }
  if (RuntimePlatform.isAndroid) {
    if (prefs.getBool("tun.perAppProxy")!) {
      if (prefs.getBool("android.tun.perAppProxy.allowed")!) {
        rules.insert(0, {
          "package_name":
              json.decode(prefs.getString("android.tun.allowedApplications")!),
          "outbound": "ot_socks"
        });
        rules.add({
          "network": ["tcp", "udp"],
          "outbound": "ot_direct"
        });
      } else {
        rules.insert(0, {
          "package_name": "com.github.anyportal.anyportal",
          "outbound": "ot_direct"
        });
        rules.insert(0, {
          "package_name": json
              .decode(prefs.getString("android.tun.disallowedApplications")!),
          "outbound": "ot_direct"
        });
      }
    } else {
      rules.insert(0, {
        "package_name": "com.github.anyportal.anyportal",
        "outbound": "ot_direct"
      });
    }
  }

  return cfg;
}

List<String> extractIps(String jsonString) {
  final ipRegex = RegExp(r'''\s*"((?:\d{1,3}\.){3}\d{1,3})"''');

  final matches = ipRegex.allMatches(jsonString);
  final ipAddresses =
      matches.map((m) => m.group(1)).whereType<String>().toList();

  return ipAddresses;
}
