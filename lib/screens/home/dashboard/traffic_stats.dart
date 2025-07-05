import 'package:flutter/material.dart';

import '../../../extensions/localization.dart';
import '../../../models/traffic_stat_type.dart';
import '../../../utils/core/base/plugin.dart';
import '../../../utils/format_byte.dart';

class TrafficStats extends StatefulWidget {
  const TrafficStats({super.key});

  @override
  State<TrafficStats> createState() => _TrafficStatsState();
}

class _TrafficStatsState extends State<TrafficStats> {
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
    final dataNotifier = CorePluginManager().instance.dataNotifier;
    return ListenableBuilder(
      listenable: dataNotifier,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            keyValueRow(
              "${context.loc.direct} ↑",
              formatBytes(
                  dataNotifier.trafficStatAgg[TrafficStatType.directUp]!),
            ),
            keyValueRow(
              "${context.loc.direct} ↓",
              formatBytes(
                  dataNotifier.trafficStatAgg[TrafficStatType.directDn]!),
            ),
            keyValueRow(
              "${context.loc.proxy} ↑",
              formatBytes(dataNotifier.trafficStatAgg[TrafficStatType.proxyUp]!),
            ),
            keyValueRow(
              "${context.loc.proxy} ↓",
              formatBytes(dataNotifier.trafficStatAgg[TrafficStatType.proxyDn]!),
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
