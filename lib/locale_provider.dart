import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App ki language manage karta hai (English / Urdu) aur device pe save.
class LocaleProvider extends ChangeNotifier {
  static const String _key = "app_language_code";

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isUrdu => _locale.languageCode == 'ur';

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _locale = Locale(code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}
