import 'package:flutter/material.dart';

import '../../../models/traffic_stat_type.dart';
import '../../../utils/core/base/plugin.dart';
import '../../../utils/format_byte.dart';

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
    return ListenableBuilder(
      listenable: CorePluginManager().instance.dataNotifier,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            keyValueRow(
              "↑",
              "${formatBytes(CorePluginManager().instance.dataNotifier.trafficStatCur[TrafficStatType.proxyUp]!)}ps",
            ),
            keyValueRow(
              "↓",
              "${formatBytes(CorePluginManager().instance.dataNotifier.trafficStatCur[TrafficStatType.proxyDn]!)}ps",
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
