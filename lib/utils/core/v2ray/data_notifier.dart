import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';

import '../../../generated/grpc/v2ray-core/app/stats/command/command.pbgrpc.dart';
import '../../../models/traffic_stat_type.dart';
import '../../logger.dart';
import '../../prefs.dart';
import '../base/data_notifier.dart';

import 'api.dart';

class CoreDataNotifierV2Ray extends CoreDataNotifierBase {
  static const protocolDirect = {
    "freedom",
    "loopback",
    "blackhole",
  };
  static const protocolProxy = {
    "dns",
    "http",
    "mtproto",
    "shadowsocks",
    "socks",
    "vmess",
    "vless",
    "trojan",
  };

  @override
  void init({String? cfgStr}) {
    super.init();

    if (cfgStr == null) return;

    final cfg = jsonDecode(cfgStr) as Map<String, dynamic>;

    if (!cfg.containsKey("outbounds")) {
      return;
    }
    final List outboundList = cfg["outbounds"];
    if (outboundList.isEmpty) {
      return;
    }
    outboundProtocol = {
      for (var map in outboundList) map['tag']: map['protocol']
    };
    apiItemTrafficStatType = {};
    for (var e in outboundProtocol.entries) {
      final tag = e.key;
      final protocol = e.value;
      if (protocolDirect.contains(protocol)) {
        apiItemTrafficStatType["outbound>>>$tag>>>traffic>>>uplink"] =
            TrafficStatType.directUp;
        apiItemTrafficStatType["outbound>>>$tag>>>traffic>>>downlink"] =
            TrafficStatType.directDn;
      } else {
        if (!protocolProxy.contains(protocol)) {
          logger.w('unknown protocol treated as proxy protocol: $protocol');
        }
        apiItemTrafficStatType["outbound>>>$tag>>>traffic>>>uplink"] =
            TrafficStatType.proxyUp;
        apiItemTrafficStatType["outbound>>>$tag>>>traffic>>>downlink"] =
            TrafficStatType.proxyDn;
      }
    }
  }

  void processStats(List<Stat> stats) {
    ++index;
    for (var t in TrafficStatType.values) {
      trafficStatPre[t] = trafficStatAgg[t]!;
      trafficStatAgg[t] = 0;
    }
    for (var stat in stats) {
      if (apiItemTrafficStatType.containsKey(stat.name)) {
        final trafficStatType = apiItemTrafficStatType[stat.name];
        trafficStatAgg[trafficStatType!] =
            trafficStatAgg[trafficStatType]! + stat.value.toInt();
      }
    }
    for (var t in TrafficStatType.values) {
      final diff = trafficStatAgg[t]! - trafficStatPre[t]!;
      if (diff < 0) {
        /// negative traffic indicates potential core restart
        trafficStatCur[t] = 0;
      } else {
        trafficStatCur[t] = diff;
      }
      trafficQs[t]!
          .add(FlSpot(index.toDouble(), trafficStatCur[t]!.toDouble()));
      while (trafficQs[t]!.length > limitCount) {
        trafficQs[t]!.removeAt(0);
      }
    }
  }

  V2RayAPI? v2RayAPI;

  @override
  Future<void> onStartCommand() async {
    final serverAddress = prefs.getString('app.server.address')!;
    final apiPort = prefs.getInt('inject.api.port')!;
    v2RayAPI = V2RayAPI(serverAddress, apiPort);
  }

  @override
  Future<void> onTick() async {
    try {
      sysStats = await v2RayAPI!.getSysStats();
      final stats = await v2RayAPI!.queryStats();
      // logger.d("${stats}");
      processStats(stats);
      // logger.d("${CorePluginManager().instance.dataNotifier.trafficStatCur}");
    } catch (e) {
      logger.d("data_watcher.start: $e");
    }
  }
}
