import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';

import '../../../models/traffic_stat_type.dart';
import '../../logger.dart';
import '../../prefs.dart';
import '../base/data_notifier.dart';

import 'api.dart';

class CoreDataNotifierClash extends CoreDataNotifierBase {
  String protocolKey = "protocol";

  @override
  void init({String? cfgStr}) {
    super.init();
  }

  @override
  void resetTraffic() {
    for (var type in [TrafficStatType.proxyDn, TrafficStatType.proxyUp]) {
      trafficStatAgg[type] = 0;
      trafficStatCur[type] = 0;
      trafficQs[type] = [];
    }
    for (index = 0; index < limitCount; ++index) {
      for (var type in [TrafficStatType.proxyDn, TrafficStatType.proxyUp]) {
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
    clashAPI!.startWatchTraffic();
  }

  Future<void> handleTrafficData(String data) async {
    Map<String, int> traffic = {};

    try {
      traffic = (jsonDecode(data) as Map).cast<String, int>();
    } catch (e) {
      logger.w('onTrafficData: failed to decode data: $data\nError: $e');
      return;
    }

    ++index;

    final trafficDn = traffic["down"]!;
    trafficStatAgg[TrafficStatType.proxyDn] =
        trafficStatAgg[TrafficStatType.proxyDn]! + trafficDn;
    trafficStatCur[TrafficStatType.proxyDn] = trafficDn;
    trafficQs[TrafficStatType.proxyDn]!
        .add(FlSpot(index.toDouble(), trafficDn.toDouble()));
    while (trafficQs[TrafficStatType.proxyDn]!.length > limitCount) {
      trafficQs[TrafficStatType.proxyDn]!.removeAt(0);
    }

    final trafficUp = traffic["up"]!;
    trafficStatAgg[TrafficStatType.proxyUp] =
        trafficStatAgg[TrafficStatType.proxyUp]! + trafficUp;
    trafficStatCur[TrafficStatType.proxyUp] = trafficUp;
    trafficQs[TrafficStatType.proxyUp]!
        .add(FlSpot(index.toDouble(), trafficUp.toDouble()));
    while (trafficQs[TrafficStatType.proxyUp]!.length > limitCount) {
      trafficQs[TrafficStatType.proxyUp]!.removeAt(0);
    }

    notifyListeners();
  }

  @override
  Future<void> onStop() async {
    clashAPI!.stopWatchTraffic();
  }
}
