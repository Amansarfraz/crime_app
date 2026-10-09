import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/api_service.dart';
import '../services/recent_store.dart';
import '../app_text.dart';
import 'crime_categories_screen.dart';
import 'crime_alerts_screen.dart';
import 'safety_tips_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'crime_assistant_screen.dart';
import 'sos_screen.dart';
import 'daily_digest_screen.dart';
import 'fake_call_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String? _crimeLevel;
  bool isLoading = false;

  List<Map<String, dynamic>> recentSearches = [];

  late stt.SpeechToText _speech;
  bool _isListening = false;

  final ApiService api = ApiService();

  late AnimationController _botAnim;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadRecent();
    _botAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _botAnim.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final saved = await RecentStore.load();
    if (!mounted) return;
    setState(() => recentSearches = saved);
  }

  Future<void> fetchCrimeRate(String city) async {
    if (city.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final data = await api.getCityCrimeLevel(city.trim());
      final level = data['crime_level'] ?? "Low";

      final item = {
        'city': data['matched_city'] ?? city,
        'country': data['country'] ?? "Pakistan",
        'level': level,
        'crime_index': data['crime_index'],
        'lat': data['lat'],
        'lng': data['lng'],
        'time': DateTime.now(),
      };

      final updated = await RecentStore.add(item);

      if (!mounted) return;
      setState(() {
        _crimeLevel = level;
        recentSearches = updated;
      });
    } catch (e) {
      debugPrint('Fetch Crime Rate Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppText.of(context).errorFetch)));
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('Status: $val'),
        onError: (val) => debugPrint('Error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            setState(() {
              _controller.text = val.recognizedWords;
            });
            if (val.finalResult && _controller.text.isNotEmpty) {
              setState(() => _isListening = false);
              await fetchCrimeRate(_controller.text);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Color getLevelColor(String level) {
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

  String localizedLevel(AppText t, String level) {
    switch (level) {
      case 'High':
        return t.high;
      case 'Medium':
        return t.medium;
      case 'Low':
        return t.low;
      default:
        return level;
    }
  }

  void _openAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CrimeAssistantScreen()),
    );
  }

  void _openDigest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DailyDigestScreen()),
    );
  }

  Widget buildQuickBox(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFF4B1CF3), Color(0xFF2488DA)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchTile(String city, String level, AppText t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color lvlColor = getLevelColor(level);
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : const Color(0xFFE9E7E7),
        ),
        color: isDark ? Colors.grey.shade900 : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: isDark ? Colors.white70 : Colors.black54,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: lvlColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: lvlColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    localizedLevel(t, level),
                    style: GoogleFonts.poppins(
                      color: lvlColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppText.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: ScaleTransition(
        scale: Tween(
          begin: 0.92,
          end: 1.06,
        ).animate(CurvedAnimation(parent: _botAnim, curve: Curves.easeInOut)),
        child: GestureDetector(
          onTap: _openAssistant,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4B1CF3), Color(0xFF2488DA)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4B1CF3).withOpacity(0.5),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.smart_toy,
                    color: Color(0xFF4B1CF3),
                    size: 30,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 4,
                  child: CircleAvatar(radius: 6, backgroundColor: Colors.green),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: const Color(0xFF2209B4),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              color: isDark ? Colors.white70 : Colors.grey,
              onPressed: () {
                if (_crimeLevel != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CrimeAlertsScreen(
                        city: _controller.text,
                        crimeLevel: _crimeLevel!,
                        recentSearches: recentSearches,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 80,
                color: const Color(0xFF2209B4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield,
                              color: Color(0xFF2209B4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              t.appName,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : const Color(0xFFE9E7E7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(
                              Icons.search,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: GoogleFonts.poppins(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                onSubmitted: (_) =>
                                    fetchCrimeRate(_controller.text),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: t.enterCity,
                                  hintStyle: GoogleFonts.poppins(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _listen,
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? Colors.red
                                    : (isDark ? Colors.white70 : Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await fetchCrimeRate(_controller.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2209B4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                t.search,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---- DAILY DIGEST BANNER ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _openDigest,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4B1CF3), Color(0xFF2488DA)],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.ur
                                    ? "روزانہ سیفٹی بریف"
                                    : "Daily Safety Brief",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                t.ur
                                    ? "آج کی تجاویز اور خطرناک علاقے دیکھیں"
                                    : "See today's tips & unsafe zones",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_crimeLevel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        "${t.crimeLevel}: ",
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getLevelColor(_crimeLevel!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: getLevelColor(_crimeLevel!),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              localizedLevel(t, _crimeLevel!),
                              style: GoogleFonts.poppins(
                                color: getLevelColor(_crimeLevel!),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildQuickBox(
                      t.crimeCategories,
                      Icons.list,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CrimeCategoriesScreen(),
                          ),
                        );
                      },
                    ),
                    buildQuickBox(
                      t.alerts,
                      Icons.warning_amber_rounded,
                      onTap: () {
                        if (_crimeLevel != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CrimeAlertsScreen(
                                city: _controller.text,
                                crimeLevel: _crimeLevel!,
                                recentSearches: recentSearches,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildQuickBox(
                      t.safetyTips,
                      Icons.verified_user,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SafetyTipsScreen(),
                          ),
                        );
                      },
                    ),
                    buildQuickBox(
                      t.settings,
                      Icons.settings,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildQuickBox(
                      t.analytics,
                      Icons.bar_chart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StatsScreen(recentSearches: recentSearches),
                          ),
                        );
                      },
                    ),
                    buildQuickBox(
                      t.map,
                      Icons.map,
                      onTap: () {
                        Navigator.pushNamed(context, '/crime_map');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildQuickBox(
                      t.aiAssistant,
                      Icons.smart_toy,
                      onTap: _openAssistant,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SosScreen()),
                        );
                      },
                      child: Container(
                        height: 100,
                        width: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [Colors.red.shade600, Colors.red.shade900],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "SOS Emergency",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- DAILY DIGEST QUICK BOX ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildQuickBox(
                      t.ur ? "روزانہ بریف" : "Daily Brief",
                      Icons.wb_sunny,
                      onTap: _openDigest,
                    ),
                    buildQuickBox(
                      t.ur ? "جعلی کال" : "Fake Call",
                      Icons.phone_in_talk,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FakeCallSetupScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.recentSearches,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (recentSearches.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          await RecentStore.clear();
                          if (!mounted) return;
                          setState(() => recentSearches = []);
                        },
                        child: Text(t.clear),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: recentSearches.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: buildSearchTile(
                        item['city'] ?? "",
                        item['level'] ?? "Low",
                        t,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
