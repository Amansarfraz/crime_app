import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/recent_store.dart';
import '../app_text.dart';

class DailyDigestScreen extends StatefulWidget {
  const DailyDigestScreen({super.key});

  @override
  State<DailyDigestScreen> createState() => _DailyDigestScreenState();
}

class _DailyDigestScreenState extends State<DailyDigestScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  List<Map<String, dynamic>> _trending = [];
  List<String> _todaysTips = [];
  Map<String, dynamic>? _yourArea;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // 1) Trending zones (backend)
    try {
      _trending = await _api.getTrendingZones();
    } catch (_) {
      _trending = [];
    }

    // 2) Your area = last recent search
    try {
      final recent = await RecentStore.load();
      if (recent.isNotEmpty) _yourArea = recent.first;
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  // din ke hisaab se 3 tips rotate
  List<String> _pickTodaysTips(List<String> all) {
    if (all.isEmpty) return [];
    final dayOfYear = int.parse(DateFormat("D").format(DateTime.now()));
    final start = (dayOfYear * 3) % all.length;
    final tips = <String>[];
    for (int i = 0; i < 3 && i < all.length; i++) {
      tips.add(all[(start + i) % all.length]);
    }
    return tips;
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppText.of(context);
    _todaysTips = _pickTodaysTips(t.safetyTipsList);
    final dateStr = DateFormat("EEEE, d MMMM yyyy").format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          t.ur ? "روزانہ سیفٹی بریف" : "Daily Safety Brief",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4B1CF3), Color(0xFF2488DA)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.wb_sunny,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t.ur ? "آج کی بریف" : "Today's Brief",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dateStr,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Your area
                  if (_yourArea != null) ...[
                    _sectionTitle(t.ur ? "آپ کا علاقہ" : "Your Area", isDark),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _levelColor(
                              (_yourArea!['level'] ?? 'Low').toString(),
                            ),
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (_yourArea!['city'] ?? '').toString(),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  "${t.crimeLevel}: ${(_yourArea!['level'] ?? 'Low')}",
                                  style: GoogleFonts.poppins(
                                    color: _levelColor(
                                      (_yourArea!['level'] ?? 'Low').toString(),
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Today's tips
                  _sectionTitle(
                    t.ur ? "آج کی حفاظتی تجاویز" : "Today's Safety Tips",
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  ..._todaysTips.asMap().entries.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: Color(0xFF4B1CF3),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                height: 1.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Trending unsafe zones
                  _sectionTitle(
                    t.ur ? "خطرناک علاقے (ٹرینڈنگ)" : "Trending Unsafe Zones",
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  if (_trending.isEmpty)
                    Text(
                      t.ur ? "کوئی ڈیٹا نہیں" : "No data available",
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    )
                  else
                    ..._trending.asMap().entries.map((entry) {
                      final i = entry.key + 1;
                      final z = entry.value;
                      final level = (z['level'] ?? 'Medium').toString();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade900 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: _levelColor(
                                level,
                              ).withOpacity(0.15),
                              child: Text(
                                "$i",
                                style: TextStyle(
                                  color: _levelColor(level),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                (z['city'] ?? '').toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _levelColor(level).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                level,
                                style: GoogleFonts.poppins(
                                  color: _levelColor(level),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
