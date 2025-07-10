import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';

import '../../prefs.dart';
import '../base/data_notifier.dart';

import 'api.dart';
import 'traffic_stat_type.dart';

class CoreDataNotifierClash extends CoreDataNotifierBase {
  String protocolKey = "protocol";

  @override
  void init({String? cfgStr}) {
    resetTraffic();
  }

  void resetTraffic() {
    for (var type in TrafficStatType.values) {
      trafficStatAgg[type] = 0;
      trafficStatCur[type] = 0;
      trafficQs[type] = [];
    }
    for (index = 0; index < limitCount; ++index) {
      for (var type in TrafficStatType.values) {
        trafficQs[type]!.add(FlSpot(index.toDouble(), 0));
      }
    }
  }

  ClashAPI? clashAPI;

  @override
  Future<void> onStart() async {
    String serverAddress = prefs.getString('app.server.address')!;
    final apiPort = prefs.getInt('inject.api.port')!;
    if (serverAddress == "0.0.0.0") {
      serverAddress = "127.0.0.1";
    }
    clashAPI = ClashAPI(serverAddress, apiPort);
    clashAPI!.onTrafficData = handleTrafficData;
    clashAPI!.onMemoryData = handleMemoryData;
    clashAPI!.startWatchTraffic();
  }

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

  final trafficKeys = {
    TrafficStatType.totalDn: "down",
    TrafficStatType.totalUp: "up",
  };

  Future<void> handleTrafficData(String data) async {
    final traffic = (jsonDecode(data) as Map).cast<String, int>();

    ++index;

    for (var type in TrafficStatType.values) {
      final trafficValue = traffic[trafficKeys[type]]!;
      trafficStatAgg[type] = trafficStatAgg[type]! + trafficValue;
      trafficStatCur[type] = trafficValue;
      trafficQs[type]!.add(FlSpot(index.toDouble(), trafficValue.toDouble()));
      while (trafficQs[type]!.length > limitCount) {
        trafficQs[type]!.removeAt(0);
      }
    }

    notifyListeners();
  }

  final Map<String, int> memory = {
    "inuse": 0,
    "oslimit": 0,
  };

  Future<void> handleMemoryData(String data) async {
    final m = (jsonDecode(data) as Map).cast<String, int>();
    memory.addAll(m);

    // notifyListeners();
  }

  @override
  Future<void> onStop() async {
    clashAPI!.stopWatchTraffic();
  }
}
