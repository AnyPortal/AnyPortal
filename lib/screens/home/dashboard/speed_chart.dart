import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../../extensions/localization.dart';
import '../../../utils/data_notifier/core/v2ray.dart';

class SpeedChart extends StatefulWidget {
  const SpeedChart({super.key});

  @override
  State<SpeedChart> createState() => _SpeedChartState();
}

class _SpeedChartState extends State<SpeedChart> {
  final limitCount = 60;

  final Map<TrafficStatType, Color> trafficColor = {
    TrafficStatType.directUp: Colors.orange,
    TrafficStatType.directDn: Colors.orange,
    TrafficStatType.proxyUp: Colors.blue,
    TrafficStatType.proxyDn: Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    // updateSpeedChart();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: coreDataNotifier,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 12,
            ),
            Stack(children: [
              AspectRatio(
                aspectRatio: 3,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: LineChart(
                    LineChartData(
                        minY: 0,
                        lineBarsData: coreDataNotifier.trafficQs
                            .map((t, q) {
                              return MapEntry(
                                  t,
                                  LineChartBarData(
                                    spots: q,
                                    dashArray:
                                        t.name.contains("Up") ? [5, 10] : null,
                                    dotData: const FlDotData(
                                      show: false,
                                    ),
                                    isCurved: false,
                                    color: trafficColor[t],
                                  ));
                            })
                            .values
                            .toList(),
                        titlesData: const FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            drawBelowEverything: true,
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              maxIncluded: false,
                              // getTitlesWidget: (value, meta) => Text(
                              //     formatBytes(value.toInt(), fractionDigits: 0)),
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        )),
                  ),
                ),
              ),
              Positioned(
                left: 44,
                top: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${context.loc.proxy} ↑ ┄┄",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      "${context.loc.proxy} ↓ ──",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      "${context.loc.direct} ↑ ┄┄",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      "${context.loc.direct} ↓ ──",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
            ]),
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
