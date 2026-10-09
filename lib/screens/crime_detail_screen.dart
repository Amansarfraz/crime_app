import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../app_text.dart';

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
  late int severity;

  @override
  void initState() {
    super.initState();
    final random = Random();
    incidentsCount = widget.localCount + random.nextInt(100);
    severity = 40 + random.nextInt(60);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppText.of(context);
    final safetyTips = t.detailTipsFor(widget.crimeKey);
    final localizedCrime = t.crimeTitleFor(widget.crimeKey);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          "$localizedCrime ${t.inWord} ${widget.cityName}",
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
            // CITY SUMMARY BOX
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
                    "${t.cityLabel}: ${widget.cityName}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "${t.crimeType}: $localizedCrime",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${t.reportedIncidents}: $incidentsCount",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${t.severityIndex}: $severity%",
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

            Text(
              t.safetyTipsColon,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2209B4),
              ),
            ),

            const SizedBox(height: 10),

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
