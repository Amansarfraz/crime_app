import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class CrimeDetailScreen extends StatefulWidget {
  final String cityName;
  final String crimeTitle;
  final String crimeKey;
  final int localCount;

  const CrimeDetailScreen({
    super.key,
    required this.cityName,
    required this.crimeTitle,
    required this.crimeKey,
    required this.localCount,
  });

  @override
  State<CrimeDetailScreen> createState() => _CrimeDetailScreenState();
}

class _CrimeDetailScreenState extends State<CrimeDetailScreen> {
  late int incidentsCount;
  late int severityIndex;
  late List<String> safetyTips;

  @override
  void initState() {
    super.initState();

    final random = Random();
    incidentsCount = widget.localCount + random.nextInt(100);
    severityIndex = 40 + random.nextInt(60);

    safetyTips = _getSafetyTips(widget.crimeKey);
  }

  List<String> _getSafetyTips(String crimeType) {
    switch (crimeType.toLowerCase()) {
      case 'theft':
        return [
          "Always lock your doors and windows.",
          "Avoid displaying valuables in public.",
          "Install a security system if possible.",
        ];
      case 'robbery':
        return [
          "Stay alert in less crowded areas.",
          "Avoid walking alone late at night.",
          "Report suspicious activity immediately.",
        ];
      case 'cybercrime':
        return [
          "Use strong and unique passwords.",
          "Avoid sharing personal info online.",
          "Keep your software up to date.",
        ];
      default:
        return ["Stay safe and alert in your area."];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          "${widget.crimeTitle} in ${widget.cityName}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ CITY SUMMARY BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : const Color(0xFFE8E9FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "City: ${widget.cityName}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Crime Type: ${widget.crimeTitle}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Reported Incidents: $incidentsCount",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Crime Severity Index: $severityIndex%",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ✅ SAFETY TITLE
            Text(
              "Safety Tips:",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2209B4),
              ),
            ),

            const SizedBox(height: 10),

            /// ✅ SAFETY LIST
            Expanded(
              child: ListView.builder(
                itemCount: safetyTips.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    color: isDark ? Colors.grey[850] : Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      title: Text(
                        safetyTips[index],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
