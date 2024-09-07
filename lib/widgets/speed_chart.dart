// import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fv2ray/utils/data_watcher.dart';

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
      listenable: dataWatcher,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // const SizedBox(height: 12),
            // Row(
            //   children: dataWatcher.trafficQs
            //       .map((t, q) {
            //         final spd = formatBytes(q.last.y.toInt());
            //         return MapEntry(
            //             t,
            //             Text(
            //               '${t.name}: ${spd}ps \t\t',
            //               style: TextStyle(
            //                 color: trafficColor[t],
            //               ),
            //             ));
            //       })
            //       .values
            //       .toList(),
            // ),
            const SizedBox(
              height: 12,
            ),
            AspectRatio(
              aspectRatio: 3,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: LineChart(
                  LineChartData(
                      minY: 0,
                      lineBarsData: dataWatcher.trafficQs
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
            )
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
