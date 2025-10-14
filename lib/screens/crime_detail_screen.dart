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

  // 1) Google Geocoding to get lat/lon from city name
  Future<Map<String, double>?> getCityCoordinates(String city) async {
    const googleApiKey = 'YOUR_GOOGLE_API_KEY_HERE'; // <-- put your key
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(city)}&key=$googleApiKey',
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body);
        if (j['results'] != null && j['results'].isNotEmpty) {
          final loc = j['results'][0]['geometry']['location'];
          return {'lat': loc['lat'].toDouble(), 'lng': loc['lng'].toDouble()};
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }

  // 2) Crimeometer call using lat/lon + incident_type
  Future<void> fetchCrimeData() async {
    setState(() => loading = true);

    const crimeApiKey =
        'YOUR_CRIMEOMETER_API_KEY_HERE'; // <-- put your key here
    final coords = await getCityCoordinates(widget.cityName);

    if (coords == null) {
      setState(() {
        data = {'error': 'Could not resolve location for ${widget.cityName}'};
        loading = false;
      });
      return;
    }

    final uri = Uri.https('api.crimeometer.com', '/v2/incidents/stats', {
      'lat': coords['lat'].toString(),
      'lon': coords['lng'].toString(),
      'datetime_ini': '2021-01-01T00:00:00Z',
      'datetime_end': '2021-12-31T00:00:00Z',
      'distance': '6mi',
      'incident_type': widget.crimeType.toLowerCase(), // try lowercase
    });

    try {
      final resp = await http.get(uri, headers: {'x-api-key': crimeApiKey});
      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body);
        // Crimeometer returns structured JSON; check for incidents_count or similar
        if (j != null &&
            (j is Map<String, dynamic>) &&
            (j.containsKey('incidents_count') || j.containsKey('incidents'))) {
          // put whatever useful fields you want into data
          setState(() {
            data = {
              'city': widget.cityName,
              'incidents_count':
                  j['incidents_count'] ?? j['incidents']?.length ?? 0,
              'csi': j['csi'] ?? 'N/A',
              'raw': j,
              'tips': [
                "Avoid isolated areas after dark",
                "Keep valuables secure",
                "Report suspicious activity",
              ],
            };
            loading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Crimeometer API error: $e');
    }

    // fallback mock if no real data
    setState(() {
      data = {
        'city': widget.cityName,
        'incidents_count': 42,
        'csi': 55,
        'tips': [
          "Avoid isolated areas after dark",
          "Keep valuables secure",
          "Report suspicious activity",
        ],
      };
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "${widget.cityName} • ${widget.crimeType}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2209B4),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text("No data found"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Overview card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                            "Overview",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          infoRow(
                            Icons.location_city,
                            "City",
                            data!['city']?.toString() ?? 'Unknown',
                          ),
                          infoRow(Icons.report, "Crime Type", widget.crimeType),
                          infoRow(
                            Icons.countertops,
                            "Incidents",
                            "${data!['incidents_count']}",
                          ),
                          infoRow(Icons.bar_chart, "CSI", "${data!['csi']}"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Safety tips
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(
                            (data!['tips'] as List).length,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      data!['tips'][i],
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
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

                    const SizedBox(height: 24),

                    // raw / debug (optional) - shows if you want to inspect API response
                    if (data != null && data!['raw'] != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          "Source data available (tap to view raw) - for debug",
                          style: GoogleFonts.poppins(fontSize: 14),
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
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
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
