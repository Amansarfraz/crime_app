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
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // 🌈 Gradient Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 55,
              left: 16,
              right: 16,
              bottom: 18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
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
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Safety Tips",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 26), // space balance for back arrow
              ],
            ),
          ),

          // 🔽 Tips List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                children: tips.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final tip = entry.value;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "$index",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 14.5,
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
