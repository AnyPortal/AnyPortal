import 'package:flutter/material.dart';

import '../../../format_byte.dart';
import '../../base/plugin.dart';
import '../data_notifier.dart';
import '../traffic_stat_type.dart';

class ProxySpeeds extends StatefulWidget {
  const ProxySpeeds({super.key});

  @override
  State<ProxySpeeds> createState() => _ProxySpeedsState();
}

class _ProxySpeedsState extends State<ProxySpeeds> {
  final limitCount = 60;

  @override
  void initState() {
    super.initState();
  }

  Widget keyValueRow(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,
        ),
        Text(
          value,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataNotifier = CorePluginManager().instance.dataNotifier as CoreDataNotifierClash;
    return ListenableBuilder(
      listenable: dataNotifier,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            keyValueRow(
              "↑",
              "${formatBytes(dataNotifier.trafficStatCur[TrafficStatType.totalUp]!)}ps",
            ),
            keyValueRow(
              "↓",
              "${formatBytes(dataNotifier.trafficStatCur[TrafficStatType.totalDn]!)}ps",
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
  }
}
