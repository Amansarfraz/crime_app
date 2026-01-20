import 'package:crime_app/screens/crime_alerts_screen.dart';
import 'package:crime_app/screens/settings_screen.dart';
import 'package:crime_app/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/home_screen.dart';
import 'screens/crime_categories_screen.dart';
import 'screens/crime_detail_screen.dart';
import 'screens/safety_tips_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/language_screen.dart';
import 'screens/log_in_screen.dart';
import 'screens/signup_screen.dart';
//import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crime Rate Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', primarySwatch: Colors.brown),

      // 🏁 First screen to show
      initialRoute: '/',

      // ✅ Define only static screens here
      routes: {
        '/': (context) => const SplashScreen(),
        '/getstartedscreen': (context) => const GetStartedScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/crime_categories_screen': (context) => const CrimeCategoriesScreen(),

        // ✅ Fixed: added required parameters for CrimeAlertsScreen
        '/crime_alerts_screen': (context) => CrimeAlertsScreen(
          city: 'Lahore',
          crimeLevel: 'High',
          recentSearches: const [],
        ),

        '/safety_tips_screen': (context) => const SafetyTipsScreen(),
        '/settings_screen': (context) => const SettingsScreen(),
        '/about_app_screen': (context) => const AboutAppScreen(),
        '/language_screen': (context) => const LanguageScreen(),
        '/signin_screen': (context) => const LogInScreen(),
        '/signup_screen': (context) => SignupScreen(),

        // ✅ Fixed: Stats screen with optional parameters
        '/stats_screen': (context) => const StatsScreen(),
        '/login': (context) => LogInScreen(),
        '/signup': (context) => SignupScreen(),
      },

      // ✅ Handle dynamic routes like CrimeDetailScreen here
      onGenerateRoute: (settings) {
        if (settings.name == '/crime_detail_screen') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CrimeDetailScreen(
              cityName: args['cityName'] ?? '',
              crimeTitle: args['crimeTitle'] ?? '',
              crimeKey: args['crimeKey'] ?? '',
              localCount: args['localCount'] ?? 0,
            ),
          );
        }

        // ✅ Handle dynamic arguments for StatsScreen
        if (settings.name == '/stats_screen') {
          final args = settings.arguments as Map<String, dynamic>?;

          return MaterialPageRoute(
            builder: (_) => StatsScreen(
              selectedCity: args?['selectedCity'] ?? 'Lahore',
              recentSearches: args?['recentSearches'] ?? const [],
            ),
          );
        }

        return null;
      },
    );
  }
}
