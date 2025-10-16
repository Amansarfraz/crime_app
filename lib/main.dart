import 'package:crime_app/screens/crime_alerts_screen.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/home_screen.dart';
import 'screens/crime_categories_screen.dart';
import 'screens/crime_detail_screen.dart';

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
        '/crime_alerts_screen': (contest) => const CrimeAlertsScreen(),
      },

      // ✅ Handle dynamic routes like CrimeDetailScreen here
      onGenerateRoute: (settings) {
        if (settings.name == '/crime_detail_screen') {
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
