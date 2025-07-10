import 'package:flutter/material.dart';

import '../../../../extensions/localization.dart';
import '../../../format_byte.dart';
import '../../base/plugin.dart';
import '../data_notifier.dart';
import '../traffic_stat_type.dart';

class TrafficStats extends StatefulWidget {
  const TrafficStats({super.key});

  @override
  State<TrafficStats> createState() => _TrafficStatsState();
}

class _TrafficStatsState extends State<TrafficStats> {
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
    final dataNotifier =
        CorePluginManager().instance.dataNotifier as CoreDataNotifierClash;
    return ListenableBuilder(
      listenable: dataNotifier,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            keyValueRow(
              "${context.loc.total} ↑",
              formatBytes(
                  dataNotifier.trafficStatAgg[TrafficStatType.totalUp]!),
            ),
            keyValueRow(
              "${context.loc.total} ↓",
              formatBytes(
                  dataNotifier.trafficStatAgg[TrafficStatType.totalDn]!),
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
