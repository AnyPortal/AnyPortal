import 'package:flutter/material.dart';

import '../traffic_stat_type.dart';
import '../../../format_byte.dart';
import '../../base/plugin.dart';
import '../data_notifier.dart';

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
    final dataNotifier = CorePluginManager().instance.dataNotifier as CoreDataNotifierV2Ray;
    return ListenableBuilder(
      listenable: dataNotifier,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            keyValueRow(
              "↑",
              "${formatBytes(dataNotifier.trafficStatCur[TrafficStatType.proxyUp]!)}ps",
            ),
            keyValueRow(
              "↓",
              "${formatBytes(dataNotifier.trafficStatCur[TrafficStatType.proxyDn]!)}ps",
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
