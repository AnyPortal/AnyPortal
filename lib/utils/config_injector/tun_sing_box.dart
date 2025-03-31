import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:anyportal/utils/vpn_manager.dart';
import '../../models/log_level.dart';
import '../global.dart';
import '../prefs.dart';

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

  if (injectHttp) {
    cfg["outbounds"].insert(0, {
      "type": "http",
      "tag": "ot_http",
      "server": injectServerAddress,
      "server_port": injectHttpPort
    });
  }

  if (injectSocks) {
    cfg["outbounds"].insert(0, {
      "type": "socks",
      "tag": "ot_socks",
      "server": injectServerAddress,
      "server_port": injectSocksPort
    });
  }

  if (injectExcludeCore) {
    final route = cfg["route"] as Map<String, dynamic>;
    if (corePath != null) {
      route["rules"].add({
        "process_path": [corePath],
        "outbound": "ot_direct"
      });
    }

    if (Platform.isAndroid) {
      route["rules"].add({
        "package_name": "com.github.anyportal.anyportal",
        "outbound": "ot_direct"
      });
    }
  }

  return cfg;
}
