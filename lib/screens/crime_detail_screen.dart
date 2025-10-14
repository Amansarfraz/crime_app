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
    const apiKey = 'YOUR_API_KEY'; // replace with your Crimeometer key
    final uri = Uri.https('api.crimeometer.com', '/v2/incidents/stats', {
      'lat': '31.5204',
      'lon': '74.3587', // Lahore example
      'datetime_ini': '2021-01-01T00:00:00Z',
      'datetime_end': '2021-12-31T00:00:00Z',
      'distance': '6mi',
      'incident_type': widget.crimeType,
    });

    try {
      final response = await http.get(uri, headers: {'x-api-key': apiKey});
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
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
          : data == null
          ? const Center(child: Text("No data found"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    "• Avoid isolated areas at night\n"
                    "• Keep emergency numbers saved\n"
                    "• Stay aware of your surroundings",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
