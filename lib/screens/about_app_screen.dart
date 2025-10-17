import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // 🔷 Header
          Container(
            height: 80,
            color: const Color(0xFF2209B4),
            padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
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
                  "About App",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🚓 Police car animation (you can change this path)
          Lottie.asset(
            'assets/animations/police.json', // 👈 Replace with your animation file path
            height: 180,
          ),

          const SizedBox(height: 10),

          // 📱 App Info
          const Text(
            "Crime Rate Alert",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Version 1.0.0",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          // 💬 Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Crime Rate Alert helps you stay informed about safety concerns in your area. "
              "Get real-time alerts, explore crime statistics, and make smart safety decisions. "
              "Stay informed, stay safe.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade700,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 🟦 Single image only (no icons or extra logos)
          Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/Group.png', // 👈 Replace with your image path
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Stay Informed, Stay Safe",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
