// import 'package:flutter/material.dart';

// class ThemeProvider extends ChangeNotifier {
//   bool _isDarkMode = false;

//   bool get isDarkMode => _isDarkMode;

//   void toggleTheme(bool value) {
//     _isDarkMode = value;
//     notifyListeners();
//   }

//   ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
// }

// import 'package:flutter/material.dart';

// class ThemeProvider extends ChangeNotifier {
//   bool _isDarkMode = false;

//   bool get isDarkMode => _isDarkMode;

//   void toggleTheme(bool value) {
//     _isDarkMode = value;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}
