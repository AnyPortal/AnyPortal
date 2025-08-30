import 'package:flutter/material.dart';

import '../../../../extensions/localization.dart';
import '../../../format_byte.dart';
import '../../base/plugin.dart';
import '../data_notifier.dart';

class PerfStats extends StatefulWidget {
  const PerfStats({super.key});

  @override
  State<PerfStats> createState() => _PerfStatsState();
}

class _PerfStatsState extends State<PerfStats> {
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
              context.loc.memory,
              formatBytes(dataNotifier.memory["inuse"]!).toString(),
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
