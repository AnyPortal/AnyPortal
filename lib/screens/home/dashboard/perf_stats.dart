import 'package:flutter/material.dart';

import '../../../extensions/localization.dart';
import '../../../utils/data_notifier/core/v2ray.dart';
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
      listenable: coreDataNotifier,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            keyValueRow(
                context.loc.uptime,
                coreDataNotifier.sysStats != null
                    ? coreDataNotifier.sysStats!.uptime.toString()
                    : "0"),
            keyValueRow(
                context.loc.memory,
                coreDataNotifier.sysStats != null
                    ? formatBytes(coreDataNotifier.sysStats!.alloc.toInt())
                    : formatBytes(0)),
            keyValueRow(
                context.loc.go_coroutines,
                coreDataNotifier.sysStats != null
                    ? coreDataNotifier.sysStats!.numGC.toString()
                    : "0"),
            keyValueRow(
                context.loc.live_objects,
                coreDataNotifier.sysStats != null
                    ? coreDataNotifier.sysStats!.liveObjects .toString()
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
