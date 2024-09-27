import 'package:flutter/material.dart';
import 'package:fv2ray/utils/data_watcher.dart';

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
      listenable: dataWatcher,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            keyValueRow(
                "uptime",
                dataWatcher.sysStats != null
                    ? dataWatcher.sysStats!.uptime.toString()
                    : "0"),
            keyValueRow(
                "memory",
                dataWatcher.sysStats != null
                    ? formatBytes(dataWatcher.sysStats!.alloc.toInt())
                    : formatBytes(0)),
            keyValueRow(
                "go coroutines",
                dataWatcher.sysStats != null
                    ? dataWatcher.sysStats!.numGC.toString()
                    : "0"),
            keyValueRow(
                "live objects",
                dataWatcher.sysStats != null
                    ? dataWatcher.sysStats!.liveObjects .toString()
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
