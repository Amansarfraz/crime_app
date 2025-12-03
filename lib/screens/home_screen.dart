import 'dart:convert';
import 'package:crime_app/screens/crime_categories_screen.dart';
import 'package:crime_app/screens/crime_alerts_screen.dart';
import 'package:crime_app/screens/safety_tips_screen.dart';
import 'package:crime_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _crimeLevel;
  List<Map<String, dynamic>> recentSearches = [];

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> fetchCrimeRate(String city) async {
    if (city.isEmpty) return;

    final normalizedCity = city.trim().toLowerCase();
    const pakistanApi =
        'https://api.jsonbin.io/v3/b/6718f0e2e41b4d34e4c9f82a/latest';

    try {
      final response = await http.get(Uri.parse(pakistanApi));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final record = data['record'] ?? {};

        for (var key in record.keys) {
          if (normalizedCity.contains(key.toLowerCase())) {
            String level = record[key];
            setState(() {
              _crimeLevel = level;
              recentSearches.insert(0, {
                'city': city,
                'level': level,
                'time': DateTime.now(),
              });
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Pakistan API error: $e');
    }

    String level;
    if (normalizedCity.contains('new york') ||
        normalizedCity.contains('mexico') ||
        normalizedCity.contains('rio') ||
        normalizedCity.contains('karachi')) {
      level = 'High';
    } else if (normalizedCity.contains('lahore') ||
        normalizedCity.contains('delhi') ||
        normalizedCity.contains('mumbai') ||
        normalizedCity.contains('london')) {
      level = 'Medium';
    } else {
      level = 'Low';
    }

    setState(() {
      _crimeLevel = level;
      recentSearches.insert(0, {
        'city': city,
        'level': level,
        'time': DateTime.now(),
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
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
              color: Colors.grey,
              onPressed: () {},
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌟 Top Bar
              Container(
                width: double.infinity,
                height: 80,
                color: const Color(0xFF2209B4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                        Text(
                          "Crime Rate Alert",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
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

              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E7E7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter City Name",
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _listen,
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening ? Colors.red : Colors.grey,
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
                        child: Text(
                          "Search",
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

              const SizedBox(height: 30),

              if (_crimeLevel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        "Crime Level: ",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
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
                              _crimeLevel!,
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

              // ⚡ Quick Access
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CrimeCategoriesScreen(),
                          ),
                        );
                      },
                      child: buildQuickBox("Crime Categories", Icons.list),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_crimeLevel != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CrimeAlertsScreen(
                                city: _controller.text,
                                crimeLevel: _crimeLevel!,
                                recentSearches: recentSearches,
                              ),
                            ),
                          );
                        }
                      },
                      child: buildQuickBox(
                        "Alerts",
                        Icons.warning_amber_rounded,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SafetyTipsScreen(),
                          ),
                        );
                      },
                      child: buildQuickBox("Safety Tips", Icons.verified_user),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: buildQuickBox("Settings", Icons.settings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Fixed Graph Section (missing closing bracket added)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_controller.text.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StatsScreen(recentSearches: recentSearches),
                            ),
                          );
                        }
                      },
                      child: buildQuickBox("Graph", Icons.bar_chart),
                    ),
                  ],
                ),
              ), // 👈 this was missing

              const SizedBox(height: 20),

              // 🕓 Recent Searches
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Recent Searches",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: recentSearches.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: buildSearchTile(item['city']!, item['level']!),
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

  Widget buildQuickBox(String title, IconData icon) {
    return Container(
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
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchTile(String city, String level) {
    Color lvlColor = getLevelColor(level);
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE9E7E7)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black54),
                const SizedBox(width: 10),
                Text(
                  city,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
                    level,
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
}
