import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? recentSearches;
  final String? selectedCity;

  const StatsScreen({super.key, this.recentSearches, this.selectedCity});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  double levelToValue(String level) {
    final l = level.toLowerCase();
    if (l == 'high') return 3.0;
    if (l == 'medium') return 2.0;
    return 1.0;
  }

  String valueToLabel(double v) {
    if (v >= 2.5) return 'High';
    if (v >= 1.5) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> data =
        (widget.recentSearches != null && widget.recentSearches!.isNotEmpty)
        ? widget.recentSearches!
        : [
            {'city': 'Karachi', 'level': 'High'},
            {'city': 'Lahore', 'level': 'Medium'},
            {'city': 'Islamabad', 'level': 'Low'},
            {'city': 'Multan', 'level': 'Medium'},
          ];

    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final level = (data[i]['level'] ?? 'Low').toString();
      final y = levelToValue(level);
      spots.add(FlSpot(i.toDouble(), y));
    }

    String bottomLabel(int index) {
      final city = data[index]['city']?.toString() ?? 'City';
      if (city.length > 10) return city.substring(0, 10) + '…';
      return city;
    }

    Widget leftTitles(double value, TitleMeta meta) {
      final label = valueToLabel(value);
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B0A57),
      appBar: AppBar(
        title: const Text('Recent Cities — Crime Trend'),
        backgroundColor: const Color(0xFF3B16BD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Line chart for your recent searched cities',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                color: const Color(0xFF22124A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: LineChart(
                    LineChartData(
                      minY: 0.8,
                      maxY: 3.2,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) {
                          return FlLine(color: Colors.white12, strokeWidth: 1);
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 56,
                            getTitlesWidget: leftTitles,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= data.length) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  bottomLabel(idx),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 12,
                          getTooltipColor: (spot) => Colors.black87,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((t) {
                              final idx = t.x.toInt();
                              final city = data[idx]['city'] ?? 'City';
                              final level = data[idx]['level'] ?? 'Low';
                              return LineTooltipItem(
                                '$city\n$level',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4B1CF3), Color(0xFF2488DA)],
                          ),
                          barWidth: 4,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2488DA).withOpacity(0.3),
                                const Color(0xFF4B1CF3).withOpacity(0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // ✅ Removed old swapAnimationDuration (no longer exists)
                    // and added duration inside AnimatedSwitcher for smooth change
                    duration: const Duration(milliseconds: 400),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(Colors.green, 'Low'),
                const SizedBox(width: 10),
                _legendDot(Colors.orange, 'Medium'),
                const SizedBox(width: 10),
                _legendDot(Colors.red, 'High'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Tap any point to see city name & level',
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
