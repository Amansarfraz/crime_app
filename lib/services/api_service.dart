import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000";
  final StorageService storage = StorageService();

  // ================== AUTH ==================
  Future<bool> signup(String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/signup");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data["access_token"] != null) {
        await storage.saveToken(data["access_token"]);
      }
      return true;
    } else {
      throw Exception("Signup failed: ${res.body}");
    }
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data["access_token"] != null) {
        await storage.saveToken(data["access_token"]);
      }
      return true;
    } else {
      throw Exception("Login failed: ${res.body}");
    }
  }

  Future<void> logout() async {
    await storage.deleteToken();
  }

  Future<Map<String, String>> _authHeader() async {
    final token = await storage.getToken();
    if (token == null || token.isEmpty)
      return {"Content-Type": "application/json"};

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ================== CRIME LEVEL ==================
  Future<Map<String, dynamic>> getCityCrimeLevel(String city) async {
    final url = Uri.parse("$baseUrl/crime/crime-level");
    final res = await http.post(
      url,
      headers: await _authHeader(),
      body: jsonEncode({"city": city.trim()}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {
        "matched_city": data["matched_city"] ?? city,
        "crime_level": data["crime_level"] ?? "Low",
        "crime_index": data["crime_index"],
        "lat": data["lat"],
        "lng": data["lng"],
        "province": data["province"] ?? "",
        "country": data["country"] ?? "Pakistan",
        "source": data["source"] ?? "fallback",
      };
    } else {
      throw Exception("Failed to fetch crime level: ${res.body}");
    }
  }

  // ================== ALL CITIES (for map markers) ==================
  Future<List<Map<String, dynamic>>> getAllCities() async {
    final url = Uri.parse("$baseUrl/crime/all-cities");
    final res = await http.get(url, headers: await _authHeader());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = (data["cities"] as List?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Failed to fetch cities: ${res.body}");
    }
  }

  // ================== AI ASSISTANT (chat) ==================
  Future<String> askAssistant(
    String message,
    List<Map<String, String>> history,
  ) async {
    final url = Uri.parse("$baseUrl/assistant/chat");
    final res = await http.post(
      url,
      headers: await _authHeader(),
      body: jsonEncode({"message": message, "history": history}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["reply"] ?? "";
    } else {
      throw Exception("Assistant error: ${res.body}");
    }
  }

  // ================== CHAT HISTORY ==================
  Future<List<Map<String, String>>> getChatHistory() async {
    final url = Uri.parse("$baseUrl/assistant/history");
    final res = await http.get(url, headers: await _authHeader());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = (data["messages"] as List?) ?? [];
      return list
          .map(
            (e) => {
              "role": (e["role"] ?? "").toString(),
              "content": (e["content"] ?? "").toString(),
            },
          )
          .toList();
    } else {
      throw Exception("History error: ${res.body}");
    }
  }

  Future<void> clearChatHistory() async {
    final url = Uri.parse("$baseUrl/assistant/history");
    final res = await http.delete(url, headers: await _authHeader());
    if (res.statusCode != 200) {
      throw Exception("Clear history error: ${res.body}");
    }
  }

  // ================== ANALYTICS ==================
  Future<Map<String, dynamic>> getAnalytics() async {
    final url = Uri.parse("$baseUrl/crime/analytics");
    final res = await http.get(url, headers: await _authHeader());

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Analytics error: ${res.body}");
    }
  }

  // ================== DAILY DIGEST (trending zones) ==================
  Future<List<Map<String, dynamic>>> getTrendingZones() async {
    final url = Uri.parse("$baseUrl/digest/trending");
    final res = await http.get(url, headers: await _authHeader());

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = (data["trending"] as List?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Digest error: ${res.body}");
    }
  }

  // ================== Other endpoints (optional) ==================
  Future<Map<String, dynamic>> getCityGraph(String city) async {
    final url = Uri.parse("$baseUrl/graphs/city/${Uri.encodeComponent(city)}");
    final res = await http.get(url, headers: await _authHeader());
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Graph error: ${res.body}");
  }

  Future<List<Map<String, String>>> getEmergencyContacts() async {
    final url = Uri.parse("$baseUrl/misc/emergency-contacts");
    final res = await http.get(url, headers: await _authHeader());
    if (res.statusCode == 200) {
      return List<Map<String, String>>.from(
        jsonDecode(
          res.body,
        ).map((e) => {"title": e["title"] ?? "", "number": e["number"] ?? ""}),
      );
    }
    throw Exception("Emergency contacts error: ${res.body}");
  }

  Future<List<String>> getSafetyTips() async {
    final url = Uri.parse("$baseUrl/misc/safety-tips");
    final res = await http.get(url, headers: await _authHeader());
    if (res.statusCode == 200)
      return List<String>.from(jsonDecode(res.body)["generic"] ?? []);
    throw Exception("Safety tips error: ${res.body}");
  }

  Future<Map<String, dynamic>> getSettings() async {
    final url = Uri.parse("$baseUrl/user/settings");
    final res = await http.get(url, headers: await _authHeader());
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Settings fetch error: ${res.body}");
  }

  Future<void> updateSettings(Map<String, dynamic> payload) async {
    final url = Uri.parse("$baseUrl/user/settings");
    final res = await http.post(
      url,
      headers: await _authHeader(),
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200)
      throw Exception("Settings update error: ${res.body}");
  }

  // API Service
  Future<Map<String, dynamic>> getCrimeDetail({
    required String city,
    required String category,
  }) async {
    final url = Uri.parse("$baseUrl/categories/city/$category");
    final res = await http.post(
      url,
      headers: await _authHeader(),
      body: jsonEncode({"city": city.trim()}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch crime details: ${res.body}");
    }
  }
}
