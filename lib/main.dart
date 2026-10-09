import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
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

import 'theme_provider.dart';
import 'locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crime Rate Alert',

      // ---------- LANGUAGE ----------
      locale: localeProvider.locale,
      supportedLocales: const [Locale('en'), Locale('ur')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ✅ LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.brown,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),

      // ✅ DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),

      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

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
