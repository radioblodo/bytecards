import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../database/database_helper.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../theme_manager.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<List<dynamic>> _allStatsFuture;

  @override
  void initState() {
    super.initState();
    _allStatsFuture = Future.wait([
      DatabaseHelper.instance.getTodayReviewCount(),
      DatabaseHelper.instance.getCardCounts(),
      DatabaseHelper.instance.getReviewHeatmapData(),
      DatabaseHelper.instance.getReviewDifficultyCounts(),
      DatabaseHelper.instance.getReviewIntervalStats(),
      DatabaseHelper.instance.getFutureDueData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.statisticsTitle)),
      body: FutureBuilder<List<dynamic>>(
        future: _allStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final todayCount = snapshot.data![0] as int;
          final cardCounts = snapshot.data![1] as Map<String, int>;
          final heatmapData = snapshot.data![2] as Map<DateTime, int>;
          final difficultyStats = snapshot.data![3] as Map<String, int>;
          final intervalStats = snapshot.data![4] as Map<String, int>;
          final futureDueData = snapshot.data![5] as List<int>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTodayBox(todayCount),
                const SizedBox(height: 16),
                _buildFutureDueBox(futureDueData),
                const SizedBox(height: 16),
                _buildCalendarBox(heatmapData),
                const SizedBox(height: 16),
                _buildReviewsBox(difficultyStats),
                const SizedBox(height: 16),
                _buildCardCountsBox(cardCounts),
                const SizedBox(height: 16),
                _buildReviewIntervalsBox(intervalStats),
              ],
            ),
          );
        },
      ),
    );
  }

  // Private method to return the today box widget
  Widget _buildTodayBox(int todayCount) {
    final loc = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.today,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                todayCount == 0
                    ? loc.noCardsReviewedToday
                    : loc.cardsReviewedToday(todayCount),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Private method to return the future due box widget
  Widget _buildFutureDueBox(List<int> futureDueData) {
    final loc = AppLocalizations.of(context)!;
    final futureDueCount = futureDueData.fold(0, (sum, e) => sum + e);

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.upcomingReviews,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: BarChart(_makeFutureDueChart(futureDueData)),
              ),
              const SizedBox(height: 8),
              Text(
                futureDueCount == 0
                    ? loc.noUpcomingReviews
                    : loc.upcomingReviewsAmt(futureDueCount),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Private method to return the future due chart widget
  BarChartData _makeFutureDueChart(List<int> futureDueData) {
    final maxY =
        futureDueData.isEmpty
            ? 10.0
            : futureDueData.reduce((a, b) => a > b ? a : b).toDouble();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY + 5,
      barGroups: List.generate(
        futureDueData.length,
        (i) => BarChartGroupData(
          x: i + 1,
          barRods: [
            BarChartRodData(
              toY: futureDueData[i].toDouble(),
              width: 12,
              borderRadius: BorderRadius.circular(4),
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            getTitlesWidget:
                (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10),
                ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final i = value.toInt() - 1;
              if (i < 0 || i >= futureDueData.length)
                return const SizedBox.shrink();
              return i % 5 == 0
                  ? Text('${i + 1}', style: TextStyle(fontSize: 10))
                  : const SizedBox.shrink();
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    );
  }

  // Private helper method to format the date
  String _fmt(DateTime d) {
    return "${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}";
  }

  // Private method to return the calendar box widget
  Widget _buildCalendarBox(Map<DateTime, int> heatmapData) {
    final loc = AppLocalizations.of(context)!;
    // Today's date
    final now = DateTime.now();

    // Function to display the number of reviews done for the day
    void showTooltip(BuildContext context, Offset offset, String text) {
      final overlay = Overlay.of(context);
      final entry = OverlayEntry(
        builder:
            (context) => Positioned(
              top: offset.dy - 40,
              left: offset.dx - 40,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
      );
      overlay.insert(entry);
      Future.delayed(const Duration(seconds: 2)).then((_) => entry.remove());
    }

    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.reviewCalendar,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: HeatMap(
                  startDate: now.subtract(const Duration(days: 90)),
                  endDate: now,
                  datasets: heatmapData,
                  colorMode: ColorMode.color,
                  showColorTip: false,
                  defaultColor: Colors.grey[300]!,
                  textColor: theme.colorScheme.onBackground,
                  colorsets: const {
                    1: Color(0xFFE8F5E9),
                    2: Color(0xFFA5D6A7),
                    3: Color(0xFF66BB6A),
                    4: Color(0xFF2E7D32),
                  },
                  onClick: (date) {
                    int count = heatmapData[date] ?? 0;
                    final fmtDate = _fmt(date);
                    final text =
                        count == 0
                            ? loc.noReviewsOnDate(fmtDate)
                            : loc.reviewsOnDate(count, fmtDate);

                    // Get tap position
                    final renderBox = context.findRenderObject() as RenderBox;
                    final offset = renderBox.globalToLocal(Offset.zero);
                    final tapPosition = Offset(
                      offset.dx + renderBox.size.width / 2,
                      offset.dy + renderBox.size.height / 2,
                    );

                    showTooltip(context, tapPosition, text);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Private method to return the reviews box widget
  Widget _buildReviewsBox(Map<String, int> difficultyStats) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Easy: ${difficultyStats['Easy']}"),
              Text("Medium: ${difficultyStats['Medium']}"),
              Text("Hard: ${difficultyStats['Hard']}"),
            ],
          ),
        ),
      ),
    );
  }

  // Private method to return the card counts box widget
  Widget _buildCardCountsBox(Map<String, int> cardCounts) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Card Counts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("New: ${cardCounts['new']}"),
              Text("Young: ${cardCounts['young']}"),
              Text("Mature: ${cardCounts['mature']}"),
            ],
          ),
        ),
      ),
    );
  }

  // Private method to return the reviews interval box widget
  Widget _buildReviewIntervalsBox(Map<String, int> intervalStats) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Review Intervals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...intervalStats.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
