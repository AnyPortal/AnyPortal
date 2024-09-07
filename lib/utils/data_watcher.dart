import 'dart:async';
import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fv2ray/utils/grpc_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generated/grpc/v2ray-core/app/stats/command/command.pbgrpc.dart';

enum TrafficStatType {
  directUp,
  directDn,
  proxyUp,
  proxyDn,
}

class DataWatcher with ChangeNotifier {
  static const protocolDirect = {"freedom"};
  static const protocolProxy = {
    "dns",
    "http",
    "mtproto",
    "shadowsocks",
    "socks",
    "vmess",
    "vless",
    "trojan"
  };

  final limitCount = 60;
  final Map<TrafficStatType, List<FlSpot>> trafficQs = {};

  final Map<TrafficStatType, int> trafficStatAgg = {
    for (var t in TrafficStatType.values) t: 0
  };
  final Map<TrafficStatType, int> trafficStatPre = {
    for (var t in TrafficStatType.values) t: 0
  };
  final Map<TrafficStatType, int> trafficStatCur = {
    for (var t in TrafficStatType.values) t: 0
  };

  late Map<String, String> outboundProtocol;
  late Map<String, TrafficStatType> apiItemTrafficStatType;
  SysStatsResponse? sysStats;

  int index = 0;

  void init(){
    for (var t in TrafficStatType.values) {
      trafficStatAgg[t] = 0;
      trafficStatPre[t] = 0;
      trafficStatCur[t] = 0;
      trafficQs[t] = [];
    }
    for (index = 0; index < limitCount; ++index) {
      for (var t in TrafficStatType.values) {
        trafficQs[t]!.add(FlSpot(index.toDouble(), 0));
      }
    }
  }

  DataWatcher(){
    init();
  }

  loadCfg(Map<String, dynamic> cfg) {
    init();

    final outboundList = cfg["outbounds"];
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
      } else if (protocolProxy.contains(protocol)) {
        apiItemTrafficStatType["outbound>>>$tag>>>traffic>>>uplink"] =
            TrafficStatType.proxyUp;
        apiItemTrafficStatType["outbound>>>$tag>>>traffic>>>downlink"] =
            TrafficStatType.proxyDn;
      }
    }
  }

  processStats(List<Stat> stats) {
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
      trafficStatCur[t] = trafficStatAgg[t]! - trafficStatPre[t]!;
      trafficQs[t]!
          .add(FlSpot(index.toDouble(), trafficStatCur[t]!.toDouble()));
      while (trafficQs[t]!.length > limitCount) {
        trafficQs[t]!.removeAt(0);
      }
    }
    notifyListeners();
  }

  Timer? timer;


  start() async {
    final prefs = await SharedPreferences.getInstance();
    final apiPort = prefs.getInt('apiPort') ?? 15490;
    final v2ApiServer = V2ApiServer("localhost", apiPort);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final stats = await v2ApiServer.queryStats();
        sysStats = await v2ApiServer.getSysStats();
        // log("${stats}");
        processStats(stats);
        // log("${dataWatcher.trafficStatCur}");
        // ignore: empty_catches
      } catch (e) {
        log("$e");
      }
    });
  }

  stop() {
    if (timer != null) timer!.cancel();
  }
}

final dataWatcher = DataWatcher();
