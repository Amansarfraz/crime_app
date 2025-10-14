import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrimeDetailScreen extends StatefulWidget {
  final String crimeType;
  const CrimeDetailScreen({super.key, required this.crimeType});

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

  Future<void> fetchCrimeData() async {
    const apiKey = 'YOUR_API_KEY_HERE'; // 🔑 Replace with your actual key

    // Default to Lahore (you can replace lat/lon dynamically by searched city)
    final uri = Uri.https('api.crimeometer.com', '/v2/incidents/stats', {
      'lat': '31.5204',
      'lon': '74.3587',
      'datetime_ini': '2021-01-01T00:00:00Z',
      'datetime_end': '2021-12-31T00:00:00Z',
      'distance': '6mi',
      'incident_type': widget.crimeType,
    });

    try {
      final response = await http.get(uri, headers: {'x-api-key': apiKey});
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json.isNotEmpty && json['incidents_count'] != null) {
          setState(() {
            data = json;
            loading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Crimeometer API error: $e");
    }

    // 🔄 Fallback (mock data if no real data found)
    setState(() {
      data = {
        'incidents_count': 120,
        'csi': 65,
        'city': 'Lahore',
        'tips': [
          "Avoid isolated areas after dark",
          "Stay alert when using public transport",
          "Report suspicious activity to authorities",
        ],
      };
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.crimeType} Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2209B4),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: data == null
                  ? const Center(child: Text("No data found"))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "City: ${data!['city'] ?? 'Unknown'}",
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Crime Type: ${widget.crimeType}",
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Total Incidents: ${data!['incidents_count'] ?? 'N/A'}",
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Crime Severity Index: ${data!['csi'] ?? 'N/A'}",
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Safety Tips:",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...List.generate(
                          (data!['tips'] ?? []).length,
                          (i) => Text(
                            "• ${data!['tips'][i]}",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
