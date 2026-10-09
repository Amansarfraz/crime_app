import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../app_text.dart';

class StatsScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? recentSearches;
  final String? selectedCity;

  const StatsScreen({super.key, this.recentSearches, this.selectedCity});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _weekly = [];
  List<Map<String, dynamic>> _monthly = [];
  List<Map<String, dynamic>> _topCities = [];
  int _totalSearches = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getAnalytics();
      setState(() {
        _weekly = List<Map<String, dynamic>>.from(data["weekly"] ?? []);
        _monthly = List<Map<String, dynamic>>.from(data["monthly"] ?? []);
        _topCities = List<Map<String, dynamic>>.from(data["top_cities"] ?? []);
        _totalSearches = data["total_searches"] ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Analytics load nahi hua. Server check karein.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(t.analytics),
        backgroundColor: const Color(0xFF3B16BD),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statCard(),
            const SizedBox(height: 24),

            // ---------- Weekly Bar Chart ----------
            _sectionTitle(t.weeklyTrends),
            _sectionSub(
              t.ur
                  ? "پچھلے 7 دن - روزانہ تلاشیں"
                  : "Last 7 days - searches per day",
            ),
            const SizedBox(height: 16),
            SizedBox(height: 220, child: _weeklyBars()),

            const SizedBox(height: 28),

            // ---------- Monthly Line Chart ----------
            _sectionTitle(t.monthlyTrends),
            _sectionSub(
              t.ur
                  ? "پچھلے 6 ماہ - کل تلاشیں"
                  : "Last 6 months - total searches",
            ),
            const SizedBox(height: 16),
            SizedBox(height: 220, child: _monthlyLine()),

            const SizedBox(height: 28),

            // ---------- Top Cities ----------
            _sectionTitle(t.topCities),
            const SizedBox(height: 12),
            _topCitiesList(),

            const SizedBox(height: 28),

            // ---------- Recent Cities Crime Level PIE ----------
            _sectionTitle(
              t.ur ? "شہروں کی جرائم سطح" : "Recent Cities — Crime Level Split",
            ),
            _sectionSub(
              t.ur
                  ? "زیادہ / درمیانہ / کم کا فیصد"
                  : "High / Medium / Low percentage",
            ),
            const SizedBox(height: 16),
            _recentCitiesPie(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // =================== STAT CARD ===================
  Widget _statCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF4B1CF3), Color(0xFF2488DA)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _loading
                  ? const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "$_totalSearches",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              Text(
                AppText.of(context).totalSearches,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      t,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _sectionSub(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        t,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  // =================== WEEKLY BARS ===================
  Widget _weeklyBars() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _errorBox();
    if (_weekly.isEmpty) return const Center(child: Text("No weekly data"));

    double maxY = 0;
    for (final d in _weekly) {
      final t = (d["total"] ?? 0).toDouble();
      if (t > maxY) maxY = t;
    }
    if (maxY < 4) maxY = 4;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _weekly.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _weekly[i]["label"] ?? "",
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(_weekly.length, (i) {
          final total = (_weekly[i]["total"] ?? 0).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: total,
                color: const Color(0xFF4B1CF3),
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // =================== MONTHLY LINE ===================
  Widget _monthlyLine() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _errorBox();
    if (_monthly.isEmpty) return const Center(child: Text("No monthly data"));

    final spots = <FlSpot>[];
    double maxY = 0;
    for (int i = 0; i < _monthly.length; i++) {
      final t = (_monthly[i]["total"] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), t));
      if (t > maxY) maxY = t;
    }
    if (maxY < 4) maxY = 4;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _monthly.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _monthly[i]["label"] ?? "",
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF2488DA),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2488DA).withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  // =================== TOP CITIES ===================
  Widget _topCitiesList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_topCities.isEmpty) {
      return Text(
        "No searches yet.",
        style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
      );
    }
    return Column(
      children: _topCities.map((c) {
        final city = c["city"] ?? "Unknown";
        final count = c["count"] ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    color: Color(0xFF4B1CF3),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    city,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B1CF3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$count searches",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4B1CF3),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // =================== RECENT CITIES PIE CHART ===================
  Widget _recentCitiesPie() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> data =
        (widget.recentSearches != null && widget.recentSearches!.isNotEmpty)
        ? widget.recentSearches!
        : [
            {'city': 'Karachi', 'level': 'High'},
            {'city': 'Lahore', 'level': 'Medium'},
            {'city': 'Islamabad', 'level': 'Low'},
            {'city': 'Multan', 'level': 'Medium'},
          ];

    // count har level ka
    int high = 0, medium = 0, low = 0;
    for (final d in data) {
      final lvl = (d['level'] ?? 'Low').toString().toLowerCase();
      if (lvl == 'high') {
        high++;
      } else if (lvl == 'medium') {
        medium++;
      } else {
        low++;
      }
    }
    final total = high + medium + low;
    if (total == 0) {
      return const Center(child: Text("No data"));
    }

    double pct(int n) => (n / total) * 100;

    final sections = <PieChartSectionData>[];
    if (high > 0) {
      sections.add(
        PieChartSectionData(
          value: high.toDouble(),
          color: Colors.red,
          title: "${pct(high).toStringAsFixed(0)}%",
          radius: 70,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
    if (medium > 0) {
      sections.add(
        PieChartSectionData(
          value: medium.toDouble(),
          color: Colors.orange,
          title: "${pct(medium).toStringAsFixed(0)}%",
          radius: 70,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
    if (low > 0) {
      sections.add(
        PieChartSectionData(
          value: low.toDouble(),
          color: Colors.green,
          title: "${pct(low).toStringAsFixed(0)}%",
          radius: 70,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // legend with counts
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            _pieLegend(Colors.red, "High", high, pct(high)),
            _pieLegend(Colors.orange, "Medium", medium, pct(medium)),
            _pieLegend(Colors.green, "Low", low, pct(low)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Total cities: $total",
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _pieLegend(Color color, String label, int count, double pct) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "$label: $count (${pct.toStringAsFixed(0)}%)",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _errorBox() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error ?? "Error", textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadAnalytics, child: const Text("Retry")),
        ],
      ),
    );
  }
}
