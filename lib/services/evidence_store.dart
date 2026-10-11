import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Saved evidence recordings (audio/video) ki list device par.
/// Har item: {type: "audio"/"video", path, time}
class EvidenceStore {
  static const String _key = "evidence_recordings";

  static Future<List<Map<String, String>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded
          .map(
            (e) => {
              "type": (e["type"] ?? "").toString(),
              "path": (e["path"] ?? "").toString(),
              "time": (e["time"] ?? "").toString(),
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, String>>> add(String type, String path) async {
    final current = await load();
    current.insert(0, {
      "type": type,
      "path": path,
      "time": DateTime.now().toIso8601String(),
    });
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
