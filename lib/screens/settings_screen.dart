// import 'package:flutter/material.dart';
// import 'language_screen.dart';
// import 'about_app_screen.dart';
// import 'logout_screen.dart'; // 👈 new screen import

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool darkMode = false;
//   bool notifications = true;
//   String selectedLanguage = 'English';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // 🔷 Header
//             Container(
//               height: 80,
//               width: double.infinity,
//               color: const Color(0xFF2209B4),
//               padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 26,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Settings",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ⚫ Dark Mode
//             _buildSettingTile(
//               icon: Icons.dark_mode,
//               color: Colors.blue.shade100,
//               title: "Dark Mode",
//               subtitle: "Switch to dark mode",
//               trailing: Switch(
//                 value: darkMode,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => setState(() => darkMode = value),
//               ),
//             ),

//             // 🔔 Notifications
//             _buildSettingTile(
//               icon: Icons.notifications_active,
//               color: Colors.blue.shade200,
//               title: "Notifications",
//               subtitle: "Enable push notifications",
//               trailing: Switch(
//                 value: notifications,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => setState(() => notifications = value),
//               ),
//             ),

//             // 🌍 Language
//             _buildSettingTile(
//               icon: Icons.language,
//               color: Colors.deepPurple.shade100,
//               title: "Language",
//               subtitle: "Selected: $selectedLanguage",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LanguageScreen()),
//                 );

//                 if (result != null && result is String) {
//                   setState(() => selectedLanguage = result);
//                 }
//               },
//             ),

//             // ℹ️ About App
//             _buildSettingTile(
//               icon: Icons.info_outline,
//               color: Colors.blue.shade100,
//               title: "About App",
//               subtitle: "App information",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AboutAppScreen()),
//                 );
//               },
//             ),

//             // 🚪 Logout Option (new)
//             _buildSettingTile(
//               icon: Icons.logout,
//               color: Colors.red.shade100,
//               title: "Logout",
//               subtitle: "Sign out from your account",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LogoutScreen()),
//                 );
//               },
//             ),

//             const SizedBox(height: 30),

//             // 🟦 App Logo Section
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Color(0xFF2209B4),
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/Group.png',
//                   width: 40,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               "Crime Rate Alert",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "Stay Informed, Stay Safe",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 color: Colors.grey,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "Version 1.0.0",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // 📱 Setting Tile Widget
//   Widget _buildSettingTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: const Color(0xFF2209B4), size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (trailing != null) trailing,
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../main.dart'; // ✅ add this
// import 'language_screen.dart';
// import 'about_app_screen.dart';
// import 'logout_screen.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool darkMode = false;
//   bool notifications = true;
//   String selectedLanguage = 'English';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ changed
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // 🔷 Header
//             Container(
//               height: 80,
//               width: double.infinity,
//               color: const Color(0xFF2209B4),
//               padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 26,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Settings",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ⚫ Dark Mode
//             _buildSettingTile(
//               icon: Icons.dark_mode,
//               color: Colors.blue.shade100,
//               title: "Dark Mode",
//               subtitle: "Switch to dark mode",
//               trailing: Switch(
//                 value: darkMode,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) {
//                   setState(() => darkMode = value);
//                   MyApp.of(context)?.toggleTheme(value); // ✅ main logic
//                 },
//               ),
//             ),

//             // 🔔 Notifications
//             _buildSettingTile(
//               icon: Icons.notifications_active,
//               color: Colors.blue.shade200,
//               title: "Notifications",
//               subtitle: "Enable push notifications",
//               trailing: Switch(
//                 value: notifications,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => setState(() => notifications = value),
//               ),
//             ),

//             // 🌍 Language
//             _buildSettingTile(
//               icon: Icons.language,
//               color: Colors.deepPurple.shade100,
//               title: "Language",
//               subtitle: "Selected: $selectedLanguage",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LanguageScreen()),
//                 );

//                 if (result != null && result is String) {
//                   setState(() => selectedLanguage = result);
//                 }
//               },
//             ),

//             // ℹ️ About App
//             _buildSettingTile(
//               icon: Icons.info_outline,
//               color: Colors.blue.shade100,
//               title: "About App",
//               subtitle: "App information",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AboutAppScreen()),
//                 );
//               },
//             ),

//             // 🚪 Logout
//             _buildSettingTile(
//               icon: Icons.logout,
//               color: Colors.red.shade100,
//               title: "Logout",
//               subtitle: "Sign out from your account",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LogoutScreen()),
//                 );
//               },
//             ),

//             const SizedBox(height: 30),

//             // 🟦 Logo
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Color(0xFF2209B4),
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/Group.png',
//                   width: 40,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               "Crime Rate Alert",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "Stay Informed, Stay Safe",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "Version 1.0.0",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor, // ✅ supports dark mode
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: const Color(0xFF2209B4), size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (trailing != null) trailing,
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'language_screen.dart';
// import 'about_app_screen.dart';
// import 'logout_screen.dart'; // 👈 new screen import

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool darkMode = false;
//   bool notifications = true;
//   String selectedLanguage = 'English';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // 🔷 Header
//             Container(
//               height: 80,
//               width: double.infinity,
//               color: const Color(0xFF2209B4),
//               padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 26,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Settings",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ⚫ Dark Mode
//             _buildSettingTile(
//               icon: Icons.dark_mode,
//               color: Colors.blue.shade100,
//               title: "Dark Mode",
//               subtitle: "Switch to dark mode",
//               trailing: Switch(
//                 value: darkMode,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => setState(() => darkMode = value),
//               ),
//             ),

//             // 🔔 Notifications
//             _buildSettingTile(
//               icon: Icons.notifications_active,
//               color: Colors.blue.shade200,
//               title: "Notifications",
//               subtitle: "Enable push notifications",
//               trailing: Switch(
//                 value: notifications,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => setState(() => notifications = value),
//               ),
//             ),

//             // 🌍 Language
//             _buildSettingTile(
//               icon: Icons.language,
//               color: Colors.deepPurple.shade100,
//               title: "Language",
//               subtitle: "Selected: $selectedLanguage",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LanguageScreen()),
//                 );

//                 if (result != null && result is String) {
//                   setState(() => selectedLanguage = result);
//                 }
//               },
//             ),

//             // ℹ️ About App
//             _buildSettingTile(
//               icon: Icons.info_outline,
//               color: Colors.blue.shade100,
//               title: "About App",
//               subtitle: "App information",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AboutAppScreen()),
//                 );
//               },
//             ),

//             // 🚪 Logout Option (new)
//             _buildSettingTile(
//               icon: Icons.logout,
//               color: Colors.red.shade100,
//               title: "Logout",
//               subtitle: "Sign out from your account",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LogoutScreen()),
//                 );
//               },
//             ),

//             const SizedBox(height: 30),

//             // 🟦 App Logo Section
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Color(0xFF2209B4),
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/Group.png',
//                   width: 40,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               "Crime Rate Alert",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "Stay Informed, Stay Safe",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 color: Colors.grey,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "Version 1.0.0",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // 📱 Setting Tile Widget
//   Widget _buildSettingTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: const Color(0xFF2209B4), size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (trailing != null) trailing,
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'language_screen.dart';
// import 'about_app_screen.dart';
// import 'logout_screen.dart';

// // 1️⃣ Theme Provider
// class ThemeProvider extends ChangeNotifier {
//   bool isDarkMode = false;

//   void toggleTheme(bool value) {
//     isDarkMode = value;
//     notifyListeners();
//   }
// }

// // 2️⃣ Light & Dark Themes
// final ThemeData lightTheme = ThemeData(
//   brightness: Brightness.light,
//   primaryColor: const Color(0xFF2209B4),
//   scaffoldBackgroundColor: const Color(0xFFF6F7FB),
//   appBarTheme: const AppBarTheme(color: Color(0xFF2209B4)),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: Colors.black),
//     bodyMedium: TextStyle(color: Colors.black87),
//   ),
// );

// final ThemeData darkTheme = ThemeData(
//   brightness: Brightness.dark,
//   primaryColor: const Color(0xFF2209B4),
//   scaffoldBackgroundColor: Colors.black,
//   appBarTheme: const AppBarTheme(color: Color(0xFF2209B4)),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: Colors.white),
//     bodyMedium: TextStyle(color: Colors.white70),
//   ),
// );

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       home: const SettingsScreen(),
//     );
//   }
// }

// // 3️⃣ Settings Screen
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool notifications = true;
//   String selectedLanguage = 'English';

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // 🔷 Header
//             Container(
//               height: 80,
//               width: double.infinity,
//               color: Theme.of(context).primaryColor,
//               padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 26,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Settings",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ⚫ Dark Mode
//             _buildSettingTile(
//               icon: Icons.dark_mode,
//               color: Colors.blue.shade100,
//               title: "Dark Mode",
//               subtitle: "Switch to dark mode",
//               trailing: Switch(
//                 value: themeProvider.isDarkMode,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) {
//                   themeProvider.toggleTheme(value);
//                 },
//               ),
//             ),

//             // 🔔 Notifications
//             _buildSettingTile(
//               icon: Icons.notifications_active,
//               color: Colors.blue.shade200,
//               title: "Notifications",
//               subtitle: "Enable push notifications",
//               trailing: Switch(
//                 value: notifications,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => setState(() => notifications = value),
//               ),
//             ),

//             // 🌍 Language
//             _buildSettingTile(
//               icon: Icons.language,
//               color: Colors.deepPurple.shade100,
//               title: "Language",
//               subtitle: "Selected: $selectedLanguage",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LanguageScreen()),
//                 );

//                 if (result != null && result is String) {
//                   setState(() => selectedLanguage = result);
//                 }
//               },
//             ),

//             // ℹ️ About App
//             _buildSettingTile(
//               icon: Icons.info_outline,
//               color: Colors.blue.shade100,
//               title: "About App",
//               subtitle: "App information",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AboutAppScreen()),
//                 );
//               },
//             ),

//             // 🚪 Logout Option
//             _buildSettingTile(
//               icon: Icons.logout,
//               color: Colors.red.shade100,
//               title: "Logout",
//               subtitle: "Sign out from your account",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LogoutScreen()),
//                 );
//               },
//             ),

//             const SizedBox(height: 30),

//             // 🟦 App Logo Section
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/Group.png',
//                   width: 40,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             Text(
//               "Crime Rate Alert",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 color: Theme.of(context).textTheme.bodyLarge?.color,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "Stay Informed, Stay Safe",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 color: Theme.of(context).textTheme.bodyMedium?.color,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "Version 1.0.0",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Theme.of(context).textTheme.bodyMedium?.color,
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // 📱 Setting Tile Widget
//   Widget _buildSettingTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).brightness == Brightness.dark
//               ? Colors.grey[900]
//               : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: const Color(0xFF2209B4), size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                       color: Theme.of(context).textTheme.bodyLarge?.color,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: Theme.of(context).textTheme.bodyMedium?.color,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (trailing != null) trailing,
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../theme_provider.dart';
// import 'language_screen.dart';
// import 'about_app_screen.dart';
// import 'logout_screen.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool notifications = true;
//   String selectedLanguage = 'English';

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               height: 80,
//               width: double.infinity,
//               color: Theme.of(context).primaryColor,
//               padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 26,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Settings",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Dark Mode toggle
//             _buildSettingTile(
//               icon: Icons.dark_mode,
//               color: Colors.blue.shade100,
//               title: "Dark Mode",
//               subtitle: "Switch to dark mode",
//               trailing: Switch(
//                 value: themeProvider.isDarkMode,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => themeProvider.toggleTheme(value),
//               ),
//             ),

//             // Notifications toggle
//             _buildSettingTile(
//               icon: Icons.notifications_active,
//               color: Colors.blue.shade200,
//               title: "Notifications",
//               subtitle: "Enable push notifications",
//               trailing: Switch(
//                 value: notifications,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => setState(() => notifications = value),
//               ),
//             ),

//             // Language
//             _buildSettingTile(
//               icon: Icons.language,
//               color: Colors.deepPurple.shade100,
//               title: "Language",
//               subtitle: "Selected: $selectedLanguage",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LanguageScreen()),
//                 );
//                 if (result != null && result is String) {
//                   setState(() => selectedLanguage = result);
//                 }
//               },
//             ),

//             // About App
//             _buildSettingTile(
//               icon: Icons.info_outline,
//               color: Colors.blue.shade100,
//               title: "About App",
//               subtitle: "App information",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AboutAppScreen()),
//                 );
//               },
//             ),

//             // Logout
//             _buildSettingTile(
//               icon: Icons.logout,
//               color: Colors.red.shade100,
//               title: "Logout",
//               subtitle: "Sign out from your account",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LogoutScreen()),
//                 );
//               },
//             ),

//             const SizedBox(height: 30),

//             // App Logo
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/Group.png',
//                   width: 40,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Crime Rate Alert",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 color: Theme.of(context).textTheme.bodyLarge?.color,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "Stay Informed, Stay Safe",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 color: Theme.of(context).textTheme.bodyMedium?.color,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "Version 1.0.0",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: Theme.of(context).textTheme.bodyMedium?.color,
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).brightness == Brightness.dark
//               ? Colors.grey[900]
//               : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: const Color(0xFF2209B4), size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                       color: Theme.of(context).textTheme.bodyLarge?.color,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: Theme.of(context).textTheme.bodyMedium?.color,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (trailing != null) trailing,
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../theme_provider.dart';
// import 'language_screen.dart';
// import 'about_app_screen.dart';
// import 'logout_screen.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool notifications = true;
//   String selectedLanguage = 'English';

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               height: 80,
//               width: double.infinity,
//               color: Theme.of(context).primaryColor,
//               padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 26,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "Settings",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Dark Mode toggle
//             _buildSettingTile(
//               icon: Icons.dark_mode,
//               color: Colors.blue.shade100,
//               title: "Dark Mode",
//               subtitle: "Switch to dark mode",
//               trailing: Switch(
//                 value: themeProvider.isDarkMode,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => themeProvider.toggleTheme(value),
//               ),
//             ),

//             // Notifications
//             _buildSettingTile(
//               icon: Icons.notifications_active,
//               color: Colors.blue.shade200,
//               title: "Notifications",
//               subtitle: "Enable push notifications",
//               trailing: Switch(
//                 value: notifications,
//                 activeColor: const Color(0xFF2209B4),
//                 onChanged: (value) => setState(() => notifications = value),
//               ),
//             ),

//             // Language
//             _buildSettingTile(
//               icon: Icons.language,
//               color: Colors.deepPurple.shade100,
//               title: "Language",
//               subtitle: "Selected: $selectedLanguage",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LanguageScreen()),
//                 );
//                 if (result != null && result is String) {
//                   setState(() => selectedLanguage = result);
//                 }
//               },
//             ),

//             // About App
//             _buildSettingTile(
//               icon: Icons.info_outline,
//               color: Colors.blue.shade100,
//               title: "About App",
//               subtitle: "App information",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AboutAppScreen()),
//                 );
//               },
//             ),

//             // Logout
//             _buildSettingTile(
//               icon: Icons.logout,
//               color: Colors.red.shade100,
//               title: "Logout",
//               subtitle: "Sign out from your account",
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LogoutScreen()),
//                 );
//               },
//             ),

//             const SizedBox(height: 30),

//             // App Logo
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 Image.asset(
//                   'assets/images/Group.png',
//                   width: 40,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Crime Rate Alert",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 color: isDark ? Colors.white : Colors.black,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "Stay Informed, Stay Safe",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 color: isDark ? Colors.white70 : Colors.black87,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "Version 1.0.0",
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 13,
//                 color: isDark ? Colors.white70 : Colors.black54,
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: isDark
//               ? Colors.grey[850]
//               : Colors.white, // only background toggle
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: const Color(0xFF2209B4), size: 24),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                       color: isDark ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 12,
//                       color: isDark ? Colors.white70 : Colors.black54,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (trailing != null) trailing,
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'language_screen.dart';
import 'about_app_screen.dart';
import 'logout_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 80,
              width: double.infinity,
              color: const Color(0xFF2209B4), // 💙 Blue for header
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
                    "Settings",
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

            // Dark Mode toggle
            _buildSettingTile(
              icon: Icons.dark_mode,
              iconBackground: Colors.blue.shade100,
              title: "Dark Mode",
              subtitle: "Switch to dark mode",
              trailing: Switch(
                value: themeProvider.isDarkMode,
                activeColor: const Color(0xFF2209B4),
                onChanged: (value) => themeProvider.toggleTheme(value),
              ),
            ),

            // Notifications
            _buildSettingTile(
              icon: Icons.notifications_active,
              iconBackground: Colors.blue.shade200,
              title: "Notifications",
              subtitle: "Enable push notifications",
              trailing: Switch(
                value: notifications,
                activeColor: const Color(0xFF2209B4),
                onChanged: (value) => setState(() => notifications = value),
              ),
            ),

            // Language
            _buildSettingTile(
              icon: Icons.language,
              iconBackground: Colors.blue.shade100, // 💙 Keep blue
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

            // About App
            _buildSettingTile(
              icon: Icons.info_outline,
              iconBackground: Colors.blue.shade100, // 💙 Keep blue
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

            // Logout
            _buildSettingTile(
              icon: Icons.logout,
              iconBackground: Colors.red.shade100, // 🔴 red for logout
              title: "Logout",
              subtitle: "Sign out from your account",
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 18,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogoutScreen()),
                );
              },
            ),

            const SizedBox(height: 30),

            // App Logo
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2209B4), // 💙 Blue background
                  ),
                ),
                Image.asset(
                  'assets/images/Group.png',
                  width: 40,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Crime Rate Alert",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Stay Informed, Stay Safe",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Version 1.0.0",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
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
                color: iconBackground,
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
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
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
