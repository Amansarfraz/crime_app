import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class CrimePredictionScreen extends StatefulWidget {
  const CrimePredictionScreen({super.key});

  @override
  State<CrimePredictionScreen> createState() => _CrimePredictionScreenState();
}

class _CrimePredictionScreenState extends State<CrimePredictionScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _cityCtrl = TextEditingController();

  bool _loading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    final city = _cityCtrl.text.trim();
    if (city.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final res = await _api.getForecast(city);
      setState(() => _result = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Forecast nahi mila. Server check karein"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _trendIcon(String t) {
    switch (t) {
      case 'rising':
        return Icons.trending_up;
      case 'falling':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          "AI Risk Forecast",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityCtrl,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onSubmitted: (_) => _predict(),
                    decoration: InputDecoration(
                      hintText: "Enter city (e.g. Karachi)",
                      filled: true,
                      fillColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _predict,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2209B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_graph, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_result != null) _buildResult(isDark),

            if (_result == null && !_loading)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights,
                        size: 70,
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Enter a city to get a 7-day\nAI safety risk forecast",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(bool isDark) {
    final level = (_result!["risk_level"] ?? "Medium").toString();
    final color = _levelColor(level);
    final city = (_result!["city"] ?? "").toString();
    final forecast = (_result!["forecast"] ?? "").toString();
    final incidents = _result!["recent_incidents"] ?? 0;
    final baseIndex = _result!["crime_index"] ?? _result!["base_index"];
    final tips = (_result!["tips"] as List?) ?? [];
    final source = (_result!["source"] ?? "").toString();
    final trend = (_result!["trend"] ?? "stable").toString();
    final peakDay = (_result!["peak_day"] ?? "").toString();
    final safestTime = (_result!["safest_time"] ?? "").toString();
    final daily = (_result!["daily"] as List?) ?? [];
    final categories = (_result!["categories"] as List?) ?? [];
    final highRisk = (_result!["high_risk_areas"] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- Risk hero card ----------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                color.withValues(alpha: 0.55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      city,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(_trendIcon(trend), color: Colors.white, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          trend.toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                "Next 7 Days Risk Forecast",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.shield, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "${level.toUpperCase()} RISK",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ---------------- Stats row ----------------
        Row(
          children: [
            _statChip(Icons.report, "$incidents", "Reports (30d)", isDark),
            const SizedBox(width: 10),
            if (baseIndex != null)
              _statChip(Icons.speed, "$baseIndex", "Crime index", isDark)
            else
              _statChip(Icons.event, peakDay, "Peak day", isDark),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statChip(Icons.event_busy, peakDay, "Peak day", isDark),
            const SizedBox(width: 10),
            _statChip(
              Icons.wb_sunny_outlined,
              safestTime,
              "Safest time",
              isDark,
            ),
          ],
        ),

        // ---------------- 7-day chart ----------------
        if (daily.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle("7-Day Risk Trend", Icons.bar_chart, isDark),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
            decoration: _boxDeco(isDark),
            child: SizedBox(
              height: 160,
              child: _BarChart(
                data: daily
                    .map(
                      (e) => _Bar(
                        (e["day"] ?? "").toString(),
                        (e["score"] as num?)?.toDouble() ?? 0,
                      ),
                    )
                    .toList(),
                isDark: isDark,
              ),
            ),
          ),
        ],

        // ---------------- Category breakdown ----------------
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle("Crime Categories (reported)", Icons.pie_chart, isDark),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _boxDeco(isDark),
            child: Column(
              children: categories.map((c) {
                final name = (c["name"] ?? "Other").toString();
                final pct = (c["percent"] as num?)?.toDouble() ?? 0;
                final cnt = c["count"] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            "${pct.toStringAsFixed(0)}%  ($cnt)",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            Color.lerp(Colors.green, Colors.red, pct / 100)!,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // ---------------- AI analysis ----------------
        const SizedBox(height: 20),
        _sectionTitle("AI Analysis", Icons.auto_awesome, isDark),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _boxDeco(isDark),
          child: Text(
            forecast,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),

        // ---------------- High risk areas ----------------
        if (highRisk.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle("Watch Out For", Icons.warning_amber, isDark),
          const SizedBox(height: 10),
          ...highRisk.map(
            (h) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.priority_high, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      h.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // ---------------- Tips ----------------
        if (tips.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle("Safety Tips", Icons.check_circle, isDark),
          const SizedBox(height: 10),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),
        Text(
          source == "ai"
              ? "⚡ Powered by AI · Estimate based on perception + community data, not official statistics."
              : "Estimate based on perception + community data, not official statistics.",
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white38 : Colors.grey,
          ),
        ),
      ],
    );
  }

  // ---------- small helpers ----------
  BoxDecoration _boxDeco(bool isDark) => BoxDecoration(
    color: isDark ? Colors.grey.shade900 : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
    ),
  );

  Widget _sectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2209B4), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _boxDeco(isDark),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2209B4)),
            const SizedBox(height: 6),
            Text(
              value.isEmpty ? "—" : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Simple bar chart (no package) =================
class _Bar {
  final String label;
  final double value; // 0-100
  _Bar(this.label, this.value);
}

class _BarChart extends StatelessWidget {
  final List<_Bar> data;
  final bool isDark;
  const _BarChart({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _BarPainter(data, isDark));
  }
}

class _BarPainter extends CustomPainter {
  final List<_Bar> data;
  final bool isDark;
  _BarPainter(this.data, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const labelH = 22.0;
    final chartH = size.height - labelH;
    final n = data.length;
    final slot = size.width / n;
    final barW = slot * 0.55;

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1;

    // grid lines (25/50/75/100)
    for (int i = 1; i <= 4; i++) {
      final y = chartH - (chartH * i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final b = data[i];
      final pct = (b.value.clamp(0, 100)) / 100.0;
      final barH = chartH * pct;
      final left = slot * i + (slot - barW) / 2;
      final top = chartH - barH;

      // color by value: green -> orange -> red
      final color = Color.lerp(Colors.green, Colors.red, pct)!;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barW, barH),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, Paint()..color = color);

      // value label
      final valTp = TextPainter(
        text: TextSpan(
          text: b.value.toStringAsFixed(0),
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(left + (barW - valTp.width) / 2, top - 14));

      // day label
      final dayTp = TextPainter(
        text: TextSpan(
          text: b.label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey,
            fontSize: 11,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dayTp.paint(canvas, Offset(left + (barW - dayTp.width) / 2, chartH + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.data != data || old.isDark != isDark;
}
