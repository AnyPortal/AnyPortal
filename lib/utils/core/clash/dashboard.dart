import 'package:flutter/material.dart';

import '../../../extensions/localization.dart';
import '../base/dashboard.dart';

import 'dashboard/perf_stats.dart';
import 'dashboard/speed_chart.dart';
import 'dashboard/total_speed.dart';
import 'dashboard/traffic_stats.dart';

class DashboardWidgetsClash extends DashboardWidgetsBase {
  @override
  List<Widget> of(BuildContext context) {
    return [
      Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              context.loc.speed_graph,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: const SpeedChart(),
          )),
      Row(children: [
        Expanded(
            child: Card(
          margin: const EdgeInsets.all(8.0),
          child: Stack(children: [
            Align(
                alignment: Directionality.of(context) == TextDirection.ltr
                    ? Alignment.topRight
                    : Alignment.topLeft,
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )),
            ListTile(
              title: Text(
                context.loc.total_speed,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: const ProxySpeeds(),
            )
          ]),
        )),
        Expanded(
          child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(context.loc.traffic),
                subtitle: TrafficStats(),
              )),
        ),
      ]),
      Row(children: <Widget>[
        Expanded(
          child: Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  context.loc.performance,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: const PerfStats(),
              )),
        ),
      ]),
    ];
  }
}
