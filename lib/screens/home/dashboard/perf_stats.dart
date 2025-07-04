import 'package:flutter/material.dart';

import '../../../extensions/localization.dart';
import '../../../utils/core/base/plugin.dart';
import '../../../utils/format_byte.dart';

class PerfStats extends StatefulWidget {
  const PerfStats({super.key});

  @override
  State<PerfStats> createState() => _PerfStatsState();
}

class _PerfStatsState extends State<PerfStats> {
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
                context.loc.uptime,
                CorePluginManager().instance.dataNotifier.sysStats != null
                    ? CorePluginManager().instance.dataNotifier.sysStats!.uptime.toString()
                    : "0"),
            keyValueRow(
                context.loc.memory,
                CorePluginManager().instance.dataNotifier.sysStats != null
                    ? formatBytes(CorePluginManager().instance.dataNotifier.sysStats!.alloc.toInt())
                    : formatBytes(0)),
            keyValueRow(
                context.loc.go_coroutines,
                CorePluginManager().instance.dataNotifier.sysStats != null
                    ? CorePluginManager().instance.dataNotifier.sysStats!.numGC.toString()
                    : "0"),
            keyValueRow(
                context.loc.live_objects,
                CorePluginManager().instance.dataNotifier.sysStats != null
                    ? CorePluginManager().instance.dataNotifier.sysStats!.liveObjects .toString()
                    : "0"),
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
