import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // 🔵 Header
          Container(
            height: 80,
            width: double.infinity,
            color: const Color(0xFF2209B4),
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                const Expanded(
                  child: Center(
                    child: Text(
                      "About App",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 🔰 Logo
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFF2209B4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 60),
          ),

          const SizedBox(height: 20),
          const Text(
            "Crime Rate Alert",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Version 1.0.0",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // 📋 Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Crime Rate Alert is designed to keep you informed about crime updates in your area. "
              "You can view safety tips, check crime categories, and receive alerts to stay safe. "
              "Our goal is to ensure your safety through awareness and instant alerts.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            "Developed by Aman Sarfraz",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
