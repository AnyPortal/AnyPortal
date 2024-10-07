import 'dart:io';

import 'package:anyportal/utils/vpn_manager.dart';
import 'package:path/path.dart' as p;

import '../../models/log_level.dart';
import '../global.dart';
import '../prefs.dart';

Future<Map<String, dynamic>> getInjectedConfigTunSingBox(
    Map<String, dynamic> cfg) async {
  final injectLog = prefs.getBool('tun.inject.log')!;
  final logLevel = LogLevel.values[prefs.getInt('tun.inject.log.level')!];
  final injectSocks = prefs.getBool('tun.inject.socks')!;
  final injectSocksPort = prefs.getInt('inject.socks.port')!;
  final injectExcludeCore = prefs.getBool('tun.inject.excludeCorePath')!;
  final corePath = vPNMan.corePath!;

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

  if (injectSocks) {
    cfg["outbounds"].insert(0, {
      "type": "socks",
      "tag": "ot_socks",
      "server": "127.0.0.1",
      "server_port": injectSocksPort
    });
  }

  if (injectExcludeCore) {
    final route = cfg["route"] as Map<String, dynamic>;
    route["rules"].insert(0, {
      "process_path": [corePath],
      "outbound": "ot_direct"
    });
  }

  return cfg;
}
