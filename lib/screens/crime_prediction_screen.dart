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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Forecast nahi mila. Server check karein")),
      );
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
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.85), color.withOpacity(0.6)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "7-Day Risk Forecast",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                ),
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

        // Stats row
        Row(
          children: [
            _statChip(
              Icons.report,
              "$incidents",
              "Recent reports",
              isDark,
            ),
            const SizedBox(width: 10),
            if (baseIndex != null)
              _statChip(
                Icons.speed,
                "$baseIndex",
                "Crime index",
                isDark,
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Forecast text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Color(0xFF2209B4), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "AI Analysis",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2209B4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                forecast,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),

        if (tips.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            "Safety Tips",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 18),
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
              )),
        ],

        const SizedBox(height: 16),
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

  Widget _statChip(IconData icon, String value, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2209B4)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
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