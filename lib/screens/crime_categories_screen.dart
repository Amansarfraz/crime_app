import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../app_text.dart';
import 'crime_detail_screen.dart';

class CrimeCategoriesScreen extends StatefulWidget {
  const CrimeCategoriesScreen({super.key});

  @override
  State<CrimeCategoriesScreen> createState() => _CrimeCategoriesScreenState();
}

class _CrimeCategoriesScreenState extends State<CrimeCategoriesScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  static const Map<String, Map<String, dynamic>> pkCityStats = {
    'lahore': {
      'population': 11126285,
      'theft': 1240,
      'robbery': 540,
      'cybercrime': 280,
      'harassment': 90,
      'assault': 620,
      'vandalism': 180,
      'fraud': 400,
      'drugs': 310,
    },
    'karachi': {
      'population': 14910352,
      'theft': 3200,
      'robbery': 1400,
      'cybercrime': 720,
      'harassment': 200,
      'assault': 1100,
      'vandalism': 420,
      'fraud': 920,
      'drugs': 680,
    },
    'islamabad': {
      'population': 1095064,
      'theft': 180,
      'robbery': 60,
      'cybercrime': 95,
      'harassment': 25,
      'assault': 140,
      'vandalism': 30,
      'fraud': 55,
      'drugs': 40,
    },
    'rawalpindi': {
      'population': 2098231,
      'theft': 420,
      'robbery': 150,
      'cybercrime': 60,
      'harassment': 35,
      'assault': 220,
      'vandalism': 68,
      'fraud': 80,
      'drugs': 90,
    },
  };

  Map<String, dynamic> _getStats(String city) {
    final key = city.toLowerCase();
    if (pkCityStats.containsKey(key)) {
      return pkCityStats[key]!;
    } else {
      final seed = city.codeUnits.fold<int>(0, (p, e) => p + e);
      return {
        'population': 500000 + (seed % 500000),
        'theft': 100 + (seed % 800),
        'robbery': 30 + (seed % 400),
        'cybercrime': 10 + (seed % 200),
        'harassment': 5 + (seed % 120),
        'assault': 40 + (seed % 600),
        'vandalism': 10 + (seed % 150),
        'fraud': 20 + (seed % 300),
        'drugs': 10 + (seed % 250),
      };
    }
  }

  Future<void> _listen(TextEditingController controller) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            controller.text = val.recognizedWords;
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final subTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.lightBlueAccent
        : const Color(0xFF2488DA);

    final List<Map<String, dynamic>> crimes = [
      {'key': 'theft', 'icon': Icons.lock_open},
      {'key': 'robbery', 'icon': Icons.remove_red_eye},
      {'key': 'cybercrime', 'icon': Icons.computer},
      {'key': 'harassment', 'icon': Icons.warning_amber_rounded},
      {'key': 'assault', 'icon': Icons.gavel},
      {'key': 'vandalism', 'icon': Icons.brush},
      {'key': 'fraud', 'icon': Icons.credit_card},
      {'key': 'drugs', 'icon': Icons.medication_liquid},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            color: const Color(0xFF2209B4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  t.crimeCategories,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: crimes.map((crime) {
                  final key = crime['key'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: double.infinity,
                      height: 199,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFEBE2E2),
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(16),
                                width: 70,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF7A6BB1,
                                  ).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  crime['icon'] as IconData,
                                  color: iconColor,
                                  size: 40,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    right: 40,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.crimeTitleFor(key),
                                        style: GoogleFonts.poppins(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        t.crimeDescFor(key),
                                        style: GoogleFonts.poppins(
                                          color: subTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: textColor,
                                size: 18,
                              ),
                              onPressed: () async {
                                final city = await showDialog<String?>(
                                  context: context,
                                  builder: (context) {
                                    final TextEditingController cityCtrl =
                                        TextEditingController();
                                    return AlertDialog(
                                      title: Text(
                                        t.enterCityDialog,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: cityCtrl,
                                              decoration: InputDecoration(
                                                hintText: t.cityHint,
                                                hintStyle: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              _isListening
                                                  ? Icons.mic
                                                  : Icons.mic_none,
                                              color: const Color(0xFF2209B4),
                                            ),
                                            onPressed: () => _listen(cityCtrl),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, null),
                                          child: Text(
                                            t.cancel,
                                            style: GoogleFonts.poppins(
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            final txt = cityCtrl.text.trim();
                                            if (txt.isEmpty) return;
                                            Navigator.pop(context, txt);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2209B4,
                                            ),
                                          ),
                                          child: Text(
                                            t.go,
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (city != null && city.isNotEmpty) {
                                  final stats = _getStats(city);
                                  final localCount = (stats[key] ?? 0) as int;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CrimeDetailScreen(
                                        cityName: city,
                                        crimeKey: key,
                                        crimeTitle: t.crimeTitleFor(key),
                                        localCount: localCount,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
