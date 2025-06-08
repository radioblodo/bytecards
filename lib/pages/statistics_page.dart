import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../database/database_helper.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<List<Map<String, dynamic>>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = DatabaseHelper.instance.getReviewStats();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.statisticsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _statsFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  final raw = snap.data!;
                  if (raw.isEmpty) {
                    return Center(
                      child: Text(
                        loc.statisticsDescription,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  // Build a full 7-day list, filling missing days with 0
                  final days = List.generate(
                    7,
                    (i) => DateTime.now().subtract(Duration(days: 6 - i)),
                  );
                  final List<Map<String, dynamic>> cardStats =
                      days.map((d) {
                        final dayStr = d.toIso8601String().substring(0, 10);
                        final match = raw.firstWhere(
                          (r) => r['day'] == dayStr,
                          orElse: () => {'day': dayStr, 'reviewed': 0},
                        );
                        // e.g. month/day label or localized weekday:
                        return {
                          'dayLabel': '${d.month}/${d.day}',
                          'reviewed': match['reviewed'] as int,
                        };
                      }).toList();

                  return BarChart(_makeChartData(cardStats));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _makeChartData(List<Map<String, dynamic>> data) {
    // 1) Find max value
    final actualMax = data
        .map((e) => (e['reviewed'] as int).toDouble())
        .fold(0.0, (m, v) => v > m ? v : m);

    // 2) Headroom & interval
    final maxY = actualMax > 0 ? actualMax * 1.1 : 5.0;
    final interval = maxY / 5;

    return BarChartData(
      maxY: maxY,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.toInt().toString(),
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),

      // 3) Axes titles
      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= data.length) return const SizedBox.shrink();
              return Text(data[i]['dayLabel']);
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),

      // 4) No grid lines
      gridData: FlGridData(show: false),

      // 5) Only two axis lines
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),

      // 6) Your bars
      barGroups:
          data.asMap().entries.map((e) {
            final idx = e.key;
            final y = (e.value['reviewed'] as int).toDouble();
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: y,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          }).toList(),
    );
  }
}
