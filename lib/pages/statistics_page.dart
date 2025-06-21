import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:simple_heatmap_calendar/simple_heatmap_calendar.dart';

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
          final intervalStats = snapshot.data![4] as Map<int, int>;
          final futureDueData = snapshot.data![5] as List<int>;

          final bottomInset =
              kBottomNavigationBarHeight +
              MediaQuery.of(context).padding.bottom;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
            child: Column(
              children: [
                _buildTodayBox(todayCount),
                const SizedBox(height: 16),
                _buildFutureDueBox(futureDueData),
                const SizedBox(height: 16),
                _buildCalendarBox(context, heatmapData),
                const SizedBox(height: 16),
                _buildReviewsBox(difficultyStats),
                const SizedBox(height: 16),
                _buildCardCountsBox(cardCounts),
                const SizedBox(height: 16),
                _buildReviewIntervalsBox(context, intervalStats),
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

  /// Builds your review calendar with localized axes (Sun→Sat, Jan→Dec or 日→六, 一月→十二月)
  /// Call this from your build():
  ///   _buildCalendarBox(context, heatmapData)
  /// Call this from your build():
  ///   _buildCalendarBox(context, heatmapData)
  Widget _buildCalendarBox(
    BuildContext context,
    Map<DateTime, int> heatmapData,
  ) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);

    // 90-day window
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 90));
    final end = now;

    // sizing constants
    const cellSize = 16.0;
    const cellGap = 4.0;
    final leftGutter = cellSize + cellGap;

    // tooltip helper
    void showTooltip(Offset globalPos, String text) {
      final overlay = Overlay.of(context);
      final entry = OverlayEntry(
        builder: (_) {
          return Positioned(
            top: globalPos.dy - 40,
            left: globalPos.dx - 40,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          );
        },
      );
      overlay.insert(entry);
      Future.delayed(const Duration(seconds: 2)).then((_) => entry.remove());
    }

    // make the labels stand out against bg in both modes
    final labelColor = theme.colorScheme.onSurface;

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
              // Header
              Text(
                loc.reviewCalendar,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Wrap in DefaultTextStyle to recolor the built-in labels
              DefaultTextStyle(
                style: TextStyle(color: labelColor),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(left: leftGutter),
                    child: HeatmapCalendar<num>(
                      // ─ Date range & locale ────────────────────────────
                      startDate: start,
                      endedDate: end,
                      locale: locale,

                      // ─ Months on top, weekdays on the left ─────────────
                      layoutParameters: const HeatmapLayoutParameters.defaults(
                        monthLabelPosition: CalendarMonthLabelPosition.top,
                        weekLabelPosition: CalendarWeekLabelPosition.left,
                        //colorTipPosition: CalendarColorTipPosition.bottom,
                      ),

                      // ─ Sizing & styling ────────────────────────────────
                      cellSize: Size.square(cellSize),
                      cellSpaceBetween: cellGap,
                      style: HeatmapCalendarStyle.defaults(
                        cellValueFontSize: 0.0,
                        weekLabelValueFontSize: 10.0,
                        weekLabelColor: labelColor,
                        monthLabelFontSize: 12.0,
                        cellRadius: const BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),

                      // ─ Your data & color thresholds ─────────────────────
                      selectedMap: heatmapData,
                      colorMap: {
                        1: const Color(0xFFE8F5E9),
                        2: const Color(0xFFA5D6A7),
                        3: const Color(0xFF66BB6A),
                        4: const Color(0xFF2E7D32),
                      },

                      // ─ Tap to show your custom tooltip ─────────────────
                      cellBuilder: (ctx, defaultCell, col, row, date) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) {
                            final count = heatmapData[date] ?? 0;
                            final fmt = DateFormat.yMMMd(
                              locale.toLanguageTag(),
                            ).format(date);
                            final msg =
                                count == 0
                                    ? loc.noReviewsOnDate(fmt)
                                    : loc.reviewsOnDate(count, fmt);
                            showTooltip(details.globalPosition, msg);
                          },
                          child: defaultCell(ctx),
                        );
                      },
                    ),
                  ),
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
    final loc = AppLocalizations.of(context)!;
    final easyCount = difficultyStats['Easy'] ?? 0;
    final mediumCount = difficultyStats['Medium'] ?? 0;
    final hardCount = difficultyStats['Hard'] ?? 0;

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
                loc.difficultyTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${loc.easyLabel}: $easyCount'),
              Text('${loc.mediumLabel}: $mediumCount'),
              Text('${loc.hardLabel}: $hardCount'),
            ],
          ),
        ),
      ),
    );
  }

  // Private method to return the card counts box widget
  Widget _buildCardCountsBox(Map<String, int> cardCounts) {
    final loc = AppLocalizations.of(context)!;
    final newCount = cardCounts['new'] ?? 0;
    final youngCount = cardCounts['young'] ?? 0;
    final matCount = cardCounts['mature'] ?? 0;

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
                loc.cardCountsTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(loc.newCards(newCount)),
              Text(loc.youngCards(youngCount)),
              Text(loc.matureCards(matCount)),
            ],
          ),
        ),
      ),
    );
  }

  // Private method to return the reviews interval box widget
  Widget _buildReviewIntervalsBox(
    BuildContext context,
    Map<int, int> intervalStats,
  ) {
    final loc = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final theme = Theme.of(context);
    final labelColor = theme.colorScheme.onBackground;

    // Build a Sunday→Saturday list of short weekday names
    final raw = DateFormat.E(localeTag).dateSymbols.WEEKDAYS;
    final labels = [
      raw[0].substring(0, 3), // Sunday
      raw[1].substring(0, 3), // Monday
      raw[2].substring(0, 3), // …
      raw[3].substring(0, 3),
      raw[4].substring(0, 3),
      raw[5].substring(0, 3),
      raw[6].substring(0, 3),
    ];

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
                loc.reviewIntervals,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 8),
              // One row per day, Sunday first
              for (var i = 0; i < 7; i++) ...[
                Text(
                  '${labels[i]}: ${intervalStats[i == 0 ? 7 : i] ?? 0}',
                  style: TextStyle(color: labelColor),
                ),
                if (i < 6) const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
