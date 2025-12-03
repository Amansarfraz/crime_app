import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'crime_detail_screen.dart';

class CrimeCategoriesScreen extends StatefulWidget {
  const CrimeCategoriesScreen({super.key});

  @override
  State<CrimeCategoriesScreen> createState() => _CrimeCategoriesScreenState();
}

class _CrimeCategoriesScreenState extends State<CrimeCategoriesScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Embedded sample dataset
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
    final List<Map<String, dynamic>> crimes = [
      {
        'title': 'Theft',
        'key': 'theft',
        'desc':
            "Unauthorized taking of someone else's property with intent to permanently deprive them of it.",
        'icon': Icons.lock_open,
      },
      {
        'title': 'Robbery',
        'key': 'robbery',
        'desc':
            "Taking property from a person using force, threat of force, or intimidation.",
        'icon': Icons.remove_red_eye,
      },
      {
        'title': 'Cybercrime',
        'key': 'cybercrime',
        'desc':
            "Criminal activities carried out using computers, networks or digital devices.",
        'icon': Icons.computer,
      },
      {
        'title': 'Harassment',
        'key': 'harassment',
        'desc':
            "Unwanted behavior that is intended to disturb or upset other person repeatedly.",
        'icon': Icons.warning_amber_rounded,
      },
      {
        'title': 'Assault',
        'key': 'assault',
        'desc':
            "Intentional act that creates fear of imminent harmful or offensive contact.",
        'icon': Icons.gavel,
      },
      {
        'title': 'Vandalism',
        'key': 'vandalism',
        'desc':
            "Deliberate destruction or damage to public or private property.",
        'icon': Icons.brush,
      },
      {
        'title': 'Fraud',
        'key': 'fraud',
        'desc':
            "Wrongful deception intended to result in financial or personal gain.",
        'icon': Icons.credit_card,
      },
      {
        'title': 'Drug Offense',
        'key': 'drugs',
        'desc':
            "Crimes related to illegal possession, distribution, or manufacturing of controlled substances.",
        'icon': Icons.medication_liquid,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
                  "Crime Categories",
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: 380,
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
                                  color: const Color(0xFF2488DA),
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
                                        crime['title'] as String,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        crime['desc'] as String,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black87,
                                          fontSize: 16,
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
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                                size: 18,
                              ),
                              onPressed: () async {
                                final city = await showDialog<String?>(
                                  context: context,
                                  builder: (context) {
                                    final TextEditingController _cityCtrl =
                                        TextEditingController();
                                    return AlertDialog(
                                      title: Text(
                                        'Enter City Name',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _cityCtrl,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'e.g. Karachi, Lahore',
                                                hintStyle: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                ),
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
                                            onPressed: () => _listen(_cityCtrl),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, null),
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            final txt = _cityCtrl.text.trim();
                                            if (txt.isEmpty) return;
                                            Navigator.pop(context, txt);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2209B4,
                                            ),
                                          ),
                                          child: Text(
                                            'Go',
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (city != null && city.isNotEmpty) {
                                  final stats = _getStats(city);
                                  final key = crime['key'] as String;
                                  final localCount = (stats[key] ?? 0) as int;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CrimeDetailScreen(
                                        cityName: city,
                                        crimeKey: key,
                                        crimeTitle: crime['title'] as String,
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
