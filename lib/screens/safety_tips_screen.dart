import 'package:flutter/material.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      "Avoid travelling late at night, especially in unfamiliar or poorly lit areas. If you must travel, stay in well-lit public spaces and inform someone of your whereabouts.",
      "Save emergency numbers in your phone including local police, ambulance, fire department and trusted contacts who can help in case of emergency.",
      "Stay alert in crowded areas such as markets, public transport, and events. Keep your belongings secure and be aware of your surroundings at all times.",
      "Don’t share personal information with strangers including your full name, address, number, or financial details. Be cautious of social engineering attempts.",
      "Trust your instincts. If something feels wrong or unsafe, remove yourself from the situation immediately and seek help from authorities or trusted individuals.",
      "Keep your mobile phone charged and carry a portable charger. Ensure location services are enabled for emergency situations and share your location with trusted contacts.",
      "Lock your home and vehicles properly. Install security cameras or smart locks if possible for better protection.",
      "Avoid displaying expensive jewelry or gadgets in public places to reduce the risk of theft.",
      "Be careful when using ATMs at night or in isolated areas. Use well-lit machines and stay alert to your surroundings.",
      "Stay informed about local crime alerts or safety updates through official apps or community groups.",
      "Always verify the identity of delivery or repair persons before letting them into your home.",
      "While driving, keep doors locked and windows slightly closed. Avoid distractions and follow traffic rules strictly.",
      "Teach children basic safety rules — like not talking to strangers and knowing how to call emergency numbers.",
      "If you feel followed or unsafe, go to a nearby public place or shop and ask for help immediately.",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          // 🔵 Simple Header
          Container(
            width: double.infinity,
            height: 80,
            color: const Color(0xFF2209B4),
            padding: const EdgeInsets.only(top: 25, left: 16, right: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Safety Tips",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 🔽 Safety Tips List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: tips.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final tip = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2209B4),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "$index",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
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
