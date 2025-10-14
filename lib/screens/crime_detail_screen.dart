import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrimeDetailScreen extends StatefulWidget {
  final String crimeType;
  final String cityName;

  const CrimeDetailScreen({
    super.key,
    required this.crimeType,
    required this.cityName,
  });

  @override
  State<CrimeDetailScreen> createState() => _CrimeDetailScreenState();
}

class _CrimeDetailScreenState extends State<CrimeDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCrimeData();
  }

  // ✅ Step 1: Get Lat/Lon from Google Geocoding API
  Future<Map<String, double>?> getCityCoordinates(String city) async {
    const googleApiKey = "YOUR_GOOGLE_API_KEY_HERE";
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?address=$city&key=$googleApiKey",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["results"].isNotEmpty) {
          final loc = data["results"][0]["geometry"]["location"];
          return {"lat": loc["lat"], "lng": loc["lng"]};
        }
      }
    } catch (e) {
      debugPrint("Geocoding API error: $e");
    }
    return null;
  }

  // ✅ Step 2: Fetch Crime Data using CrimeoMeter API
  Future<void> fetchCrimeData() async {
    const crimeApiKey = "YOUR_API_KEY_HERE";
    final coords = await getCityCoordinates(widget.cityName);

    if (coords == null) {
      setState(() {
        data = {"error": "Could not fetch location for ${widget.cityName}"};
        loading = false;
      });
      return;
    }

    final uri = Uri.https('api.crimeometer.com', '/v2/incidents/stats', {
      'lat': coords["lat"].toString(),
      'lon': coords["lng"].toString(),
      'datetime_ini': '2021-01-01T00:00:00Z',
      'datetime_end': '2021-12-31T00:00:00Z',
      'distance': '6mi',
      'incident_type': widget.crimeType,
    });

    try {
      final response = await http.get(uri, headers: {'x-api-key': crimeApiKey});
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json.isNotEmpty && json['incidents_count'] != null) {
          setState(() {
            data = {
              ...json,
              "city": widget.cityName,
              "tips": [
                "Avoid isolated areas after dark",
                "Stay alert when using public transport",
                "Report suspicious activity to authorities",
              ],
            };
            loading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Crimeometer API error: $e");
    }

    // fallback mock data
    setState(() {
      data = {
        "city": widget.cityName,
        "incidents_count": 45,
        "csi": 58,
        "tips": [
          "Avoid isolated areas after dark",
          "Keep your valuables secure",
          "Report suspicious activities to police",
        ],
      };
      loading = false;
    });
  }

  // ✅ Step 3: Build Beautiful UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "${widget.cityName} - ${widget.crimeType}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2209B4),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : data == null
          ? const Center(child: Text("No data found"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Gradient card for stats
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Crime Overview",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          infoRow(
                            Icons.location_city,
                            "City",
                            data!["city"] ?? "Unknown",
                          ),
                          infoRow(Icons.shield, "Crime Type", widget.crimeType),
                          infoRow(
                            Icons.numbers,
                            "Total Incidents",
                            "${data!['incidents_count']}",
                          ),
                          infoRow(
                            Icons.warning_amber,
                            "Crime Severity Index",
                            "${data!['csi']}",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Safety Tips Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Safety Tips",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(
                            (data!["tips"] ?? []).length,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.blueAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      data!["tips"][i],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
