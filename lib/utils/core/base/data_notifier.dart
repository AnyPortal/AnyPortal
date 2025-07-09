import 'dart:async';

import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../../generated/grpc/v2ray-core/app/stats/command/command.pbgrpc.dart';
import '../../../models/traffic_stat_type.dart';

class CoreDataNotifierBase with ChangeNotifier {
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
  bool on = false;

  CoreDataNotifierBase() {
    resetTraffic();
  }

  void init({String? cfgStr}) {
    resetTraffic();
  }

  void resetTraffic() {
    for (var type in TrafficStatType.values) {
      trafficStatAgg[type] = 0;
      trafficStatPre[type] = 0;
      trafficStatCur[type] = 0;
      trafficQs[type] = [];
    }
    for (index = 0; index < limitCount; ++index) {
      for (var type in TrafficStatType.values) {
        trafficQs[type]!.add(FlSpot(index.toDouble(), 0));
      }
    }
  }

  Future<void> onStart() async {}
  Future<void> onStop() async {}

  Future<void> start() async {
    if (on) {
      return;
    } else {
      on = true;
    }
    await onStart();
  }

  Future<void> stop() async {
    await onStop();
    on = false;
  }
}
