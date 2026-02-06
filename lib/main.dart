// import 'package:crime_app/screens/crime_alerts_screen.dart';
// import 'package:crime_app/screens/settings_screen.dart';
// import 'package:crime_app/screens/stats_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart'; // FlutterFire generated options
// import 'screens/splash_screen.dart';
// import 'screens/get_started_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/crime_categories_screen.dart';
// import 'screens/crime_detail_screen.dart';
// import 'screens/safety_tips_screen.dart';
// import 'screens/about_app_screen.dart';
// import 'screens/language_screen.dart';
// import 'screens/log_in_screen.dart';
// import 'screens/signup_screen.dart';
// //import 'services/auth_service.dart'; // Firebase auth logic

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Firebase initialization for ALL platforms
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Crime Rate Alert',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(fontFamily: 'Poppins', primarySwatch: Colors.brown),

//       // 🏁 First screen to show
//       initialRoute: '/',

//       // ✅ Static screens
//       routes: {
//         '/': (context) => const SplashScreen(),
//         '/getstartedscreen': (context) => const GetStartedScreen(),
//         '/home_screen': (context) => const HomeScreen(),
//         '/crime_categories_screen': (context) => const CrimeCategoriesScreen(),
//         '/crime_alerts_screen': (context) => CrimeAlertsScreen(
//           city: 'Lahore',
//           crimeLevel: 'High',
//           recentSearches: const [],
//         ),
//         '/safety_tips_screen': (context) => const SafetyTipsScreen(),
//         '/settings_screen': (context) => const SettingsScreen(),
//         '/about_app_screen': (context) => const AboutAppScreen(),
//         '/language_screen': (context) => const LanguageScreen(),
//         '/signin_screen': (context) => const LogInScreen(),
//         '/signup_screen': (context) => SignupScreen(),
//         '/stats_screen': (context) => const StatsScreen(),
//         '/login': (context) => LogInScreen(),
//         '/signup': (context) => SignupScreen(),
//       },

//       // ✅ Dynamic routes
//       onGenerateRoute: (settings) {
//         if (settings.name == '/crime_detail_screen') {
//           final args = settings.arguments as Map<String, dynamic>;
//           return MaterialPageRoute(
//             builder: (_) => CrimeDetailScreen(
//               cityName: args['cityName'] ?? '',
//               crimeTitle: args['crimeTitle'] ?? '',
//               crimeKey: args['crimeKey'] ?? '',
//               localCount: args['localCount'] ?? 0,
//             ),
//           );
//         }

//         if (settings.name == '/stats_screen') {
//           final args = settings.arguments as Map<String, dynamic>?;

//           return MaterialPageRoute(
//             builder: (_) => StatsScreen(
//               selectedCity: args?['selectedCity'] ?? 'Lahore',
//               recentSearches: args?['recentSearches'] ?? const [],
//             ),
//           );
//         }

//         return null;
//       },

//       // ✅ Optional: AuthGuard (Redirect to Login if not logged in)
//       builder: (context, child) {
//         // Example: Firebase Auth check for Web
//         final user = FirebaseAuth.instance.currentUser;
//         if (user == null &&
//             ModalRoute.of(context)?.settings.name != '/signin_screen' &&
//             ModalRoute.of(context)?.settings.name != '/signup_screen') {
//           return const LogInScreen();
//         }
//         return child!;
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/home_screen.dart';
import 'screens/log_in_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/crime_categories_screen.dart';
import 'screens/crime_alerts_screen.dart';
import 'screens/safety_tips_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/language_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/crime_detail_screen.dart';
import 'screens/crime_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/getstartedscreen': (context) => const GetStartedScreen(),
        '/login': (context) => const LogInScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/crime_categories': (context) => const CrimeCategoriesScreen(),
        '/crime_alerts': (context) => CrimeAlertsScreen(
          city: 'Lahore',
          crimeLevel: 'High',
          recentSearches: const [],
        ),
        '/safety_tips': (context) => const SafetyTipsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/about': (context) => const AboutAppScreen(),
        '/language': (context) => const LanguageScreen(),
        '/stats': (context) => const StatsScreen(),
        '/crime_map': (context) => const CrimeMapScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/crime_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CrimeDetailScreen(
              cityName: args['cityName'],
              crimeTitle: args['crimeTitle'],
              crimeKey: args['crimeKey'],
              localCount: args['localCount'],
            ),
          );
        }
        return null;
      },
    );
  }
}
