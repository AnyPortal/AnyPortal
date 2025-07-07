import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';

import '../../../generated/grpc/v2ray-core/app/stats/command/command.pbgrpc.dart';
import '../../../models/traffic_stat_type.dart';
import '../../logger.dart';
import '../../prefs.dart';
import '../base/data_notifier.dart';

import 'api.dart';

class CoreDataNotifierClash extends CoreDataNotifierBase {
  Set<String> protocolDirect = {
    "freedom",
    "loopback",
    "blackhole",
  };
  Set<String> protocolProxy = {
    "dns",
    "http",
    "mtproto",
    "shadowsocks",
    "socks",
    "vmess",
    "vless",
    "trojan",
  };

  String protocolKey = "protocol";

  @override
  void init({String? cfgStr}) {
    super.init();
  }

  void processStats(List<Stat> stats) {}

  ClashAPI? clashAPI;

  @override
  Future<void> onStartCommand() async {
    final serverAddress = prefs.getString('app.server.address')!;
    final apiPort = prefs.getInt('inject.api.port')!;
    clashAPI = ClashAPI(serverAddress, apiPort);
  }

  @override
  Future<void> onTick() async {
    try {
      // logger.d("${stats}");
      // logger.d("${CorePluginManager().instance.dataNotifier.trafficStatCur}");
    } catch (e) {
      logger.d("data_watcher.start: $e");
    }
  }
}
