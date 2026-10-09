import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Recent searches ko device par save/load karta hai (shared_preferences).
/// HomeScreen kitni bhi baar dobara bane, data nahi udega.
class RecentStore {
  static const String _key = "recent_searches";

  /// Saari recent searches load karo (latest pehle).
  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) {
        final m = Map<String, dynamic>.from(e);
        // time string ko DateTime me wapas convert karo
        if (m['time'] is String) {
          m['time'] = DateTime.tryParse(m['time']) ?? DateTime.now();
        }
        return m;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Ek nayi search add karo (top par). Duplicate city hata ke max 10 rakhta hai.
  static Future<List<Map<String, dynamic>>> add(
    Map<String, dynamic> item,
  ) async {
    final current = await load();

    // wahi city dobara aaye to purani entry hata do
    final cityName = (item['city'] ?? '').toString().toLowerCase();
    current.removeWhere(
      (e) => (e['city'] ?? '').toString().toLowerCase() == cityName,
    );

    current.insert(0, item);

    // max 10 recent
    final trimmed = current.take(10).toList();

    await _save(trimmed);
    return trimmed;
  }

  /// Saari recent searches clear karo.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _save(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();

    // DateTime ko string me convert karo (JSON safe)
    final encodable = list.map((e) {
      final m = Map<String, dynamic>.from(e);
      if (m['time'] is DateTime) {
        m['time'] = (m['time'] as DateTime).toIso8601String();
      }
      return m;
    }).toList();

    await prefs.setString(_key, jsonEncode(encodable));
  }
}
