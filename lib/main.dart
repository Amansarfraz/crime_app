import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/home_screen.dart';
import 'screens/crime_categories_screen.dart';
import 'screens/crime_detail_screen.dart'; // ✅ Correct import

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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // ✅ Handles routes that need arguments
        if (settings.name == '/crime_detail_screen') {
          final crimeType = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => CrimeDetailScreen(
              crimeType: crimeType,
              cityName: 'YourCityName',
            ),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/getstartedscreen': (context) => const GetStartedScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/crime_categories_screen': (context) => const CrimeCategoriesScreen(),
      },
    );
  }
}
