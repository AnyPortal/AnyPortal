import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../../../extensions/localization.dart';
import '../../../format_byte.dart';
import '../../base/plugin.dart';
import '../data_notifier.dart';
import '../traffic_stat_type.dart';

class SpeedChart extends StatefulWidget {
  const SpeedChart({super.key});

  @override
  State<SpeedChart> createState() => _SpeedChartState();
}

class _SpeedChartState extends State<SpeedChart> {
  final Map<TrafficStatType, Color> trafficColor = {
    TrafficStatType.totalUp: Colors.blue,
    TrafficStatType.totalDn: Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    // updateSpeedChart();
  }

  @override
  Widget build(BuildContext context) {
    final dataNotifier =
        CorePluginManager().instance.dataNotifier as CoreDataNotifierClash;
    return ListenableBuilder(
      listenable: dataNotifier,
      builder: (BuildContext context, Widget? child) {
        final l = dataNotifier.trafficQs.values.first;
        final minX = l.last.x - l.length + 1;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        minX: minX,
                        lineBarsData: dataNotifier.trafficQs
                            .map((t, q) {
                              return MapEntry(
                                t,
                                LineChartBarData(
                                  spots: q,
                                  dashArray: t.name.contains("Up")
                                      ? [5, 10]
                                      : null,
                                  dotData: const FlDotData(show: false),
                                  isCurved: false,
                                  color: trafficColor[t],
                                ),
                              );
                            })
                            .values
                            .toList(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            drawBelowEverything: true,
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 48,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  removeLastChar(
                                    formatBytes(
                                      value.toInt(),
                                      fractionDigits: 1,
                                      base: 1000,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                      duration: minX == 1
                          ? Duration.zero
                          : const Duration(milliseconds: 150),
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
                        "${context.loc.total} ↑ ┄┄",
                        style: TextStyle(color: Colors.blue, fontSize: 10),
                      ),
                      Text(
                        "${context.loc.total} ↓ ──",
                        style: TextStyle(color: Colors.blue, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
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

String removeLastChar(String s) {
  if (s.isEmpty) {
    return s;
  }
  return s.substring(0, s.length - 1);
}
