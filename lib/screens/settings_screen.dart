import 'package:flutter/material.dart';
import 'language_screen.dart';
import 'about_app_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool notifications = true;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // 🔷 Header
          Container(
            height: 80,
            width: double.infinity,
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
                const Expanded(
                  child: Center(
                    child: Text(
                      "Settings",
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

          const SizedBox(height: 20),

          // ⚫ Dark Mode
          _buildSettingTile(
            icon: Icons.dark_mode,
            color: Colors.blue.shade100,
            title: "Dark Mode",
            subtitle: "Switch to dark mode",
            trailing: Switch(
              value: darkMode,
              activeColor: const Color(0xFF2209B4),
              onChanged: (value) => setState(() => darkMode = value),
            ),
          ),

          // 🔔 Notifications
          _buildSettingTile(
            icon: Icons.notifications_active,
            color: Colors.blue.shade200,
            title: "Notifications",
            subtitle: "Enable push notifications",
            trailing: Switch(
              value: notifications,
              activeColor: const Color(0xFF2209B4),
              onChanged: (value) => setState(() => notifications = value),
            ),
          ),

          // 🌍 Language
          _buildSettingTile(
            icon: Icons.language,
            color: Colors.deepPurple.shade100,
            title: "Language",
            subtitle: "Selected: $selectedLanguage",
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 18,
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );

              if (result != null && result is String) {
                setState(() => selectedLanguage = result);
              }
            },
          ),

          // ℹ️ About App
          _buildSettingTile(
            icon: Icons.info_outline,
            color: Colors.blue.shade100,
            title: "About App",
            subtitle: "App information",
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 18,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen()),
              );
            },
          ),

          const SizedBox(height: 30),

          // 🖼️ Image Placeholder Only (no logo icons)
          Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/Group.png', // 👈 Put your own image path here
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Crime Rate Alert",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
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
              const SizedBox(height: 6),
              const Text(
                "Stay Informed, Stay Safe",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📱 Setting Tile Widget
  Widget _buildSettingTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF2209B4), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
