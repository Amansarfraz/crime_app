import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'crime_detail_screen.dart';

class CrimeCategoriesScreen extends StatelessWidget {
  const CrimeCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> crimes = [
      {
        'title': 'Theft',
        'desc':
            "Unauthorized taking of someone else's property with intend to permanently deprive them of it.",
        'icon': Icons.lock_open,
      },
      {
        'title': 'Robbery',
        'desc':
            "Taking property from a person using force, threat of force, or intimidation.",
        'icon': Icons.remove_red_eye,
      },
      {
        'title': 'Cybercrime',
        'desc':
            "Criminal activities carried out using computers, networks or digital devices.",
        'icon': Icons.computer,
      },
      {
        'title': 'Harassment',
        'desc':
            "Unwanted behavior that is intended to disturb or upset other person repeatedly.",
        'icon': Icons.warning_amber_rounded,
      },
      {
        'title': 'Assault',
        'desc':
            "Intentional act that creates fear of imminent harmful or offensive contact.",
        'icon': Icons.gavel,
      },
      {
        'title': 'Vandalism',
        'desc':
            "Deliberate destruction or damage to public or private property.",
        'icon': Icons.brush,
      },
      {
        'title': 'Fraud',
        'desc':
            "Wrongful deception intented to result in financial or personal gain.",
        'icon': Icons.credit_card,
      },
      {
        'title': 'Drug Offense',
        'desc':
            "Crimes related to illegal possession, distribution, or manufacturing of controlled substances.",
        'icon': Icons.medication_liquid,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔷 Top Blue Bar
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

          // 📜 Scrollable content
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
                              // 🟪 Left icon box
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

                              // 📖 Text section
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    right: 40, // space for arrow
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

                          // ➡️ Arrow button (bottom-right)
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                                size: 18,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CrimeDetailScreen(
                                      crimeType: crime['title'] as String,
                                      cityName:
                                          'YourCityName', // Replace with actual city name variable if available
                                    ),
                                  ),
                                );
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
