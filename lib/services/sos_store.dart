import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Emergency (SOS) contacts device par save/load karta hai.
/// Har contact: {name, number}
class SosStore {
  static const String _key = "sos_contacts";

  static Future<List<Map<String, String>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded
          .map(
            (e) => {
              "name": (e["name"] ?? "").toString(),
              "number": (e["number"] ?? "").toString(),
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, String>>> add(
    String name,
    String number,
  ) async {
    final current = await load();
    current.add({"name": name.trim(), "number": number.trim()});
    await _save(current);
    return current;
  }

  static Future<List<Map<String, String>>> removeAt(int index) async {
    final current = await load();
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      await _save(current);
    }
    return current;
  }

  static Future<void> _save(List<Map<String, String>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
  }
}
