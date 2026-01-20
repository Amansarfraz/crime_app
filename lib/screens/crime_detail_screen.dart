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

    // Generate random simulated data
    final random = Random();
    incidentsCount = widget.localCount + random.nextInt(100);
    severityIndex = 40 + random.nextInt(60);

    // Sample safety tips based on crime type
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
      case 'harassment':
        return [
          "Block and report the harasser immediately.",
          "Do not engage or respond to offensive messages.",
          "Reach out to local authorities or helplines.",
        ];
      case 'assault':
        return [
          "Avoid isolated or dark places alone.",
          "Carry a whistle or safety alarm.",
          "Stay aware of your surroundings.",
        ];
      case 'vandalism':
        return [
          "Report damaged property to authorities.",
          "Install outdoor lighting and cameras.",
          "Keep community areas monitored.",
        ];
      case 'fraud':
        return [
          "Never share bank details with strangers.",
          "Be cautious of too-good-to-be-true offers.",
          "Verify unknown calls or emails before responding.",
        ];
      case 'drug offense':
        return [
          "Avoid areas known for illegal activity.",
          "Report suspicious substance exchange.",
          "Encourage awareness in your community.",
        ];
      default:
        return ["Stay safe and alert in your area."];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          "${widget.crimeTitle} in ${widget.cityName}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏙 City & Crime Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E9FF),
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Crime Type: ${widget.crimeTitle}",
                    style: GoogleFonts.poppins(fontSize: 18),
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

            // 💡 Safety Tips Section
            Text(
              "Safety Tips:",
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
                        style: GoogleFonts.poppins(fontSize: 16),
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

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../services/api_service.dart';

// class CrimeDetailScreen extends StatefulWidget {
//   final String cityName;
//   final String crimeTitle;
//   final String crimeKey;
//   final int localCount;

//   const CrimeDetailScreen({
//     super.key,
//     required this.cityName,
//     required this.crimeTitle,
//     required this.crimeKey,
//     required this.localCount,
//   });

//   @override
//   State<CrimeDetailScreen> createState() => _CrimeDetailScreenState();
// }

// class _CrimeDetailScreenState extends State<CrimeDetailScreen> {
//   final ApiService api = ApiService();

//   bool isLoading = true;
//   String? error;

//   int incidentsCount = 0;
//   int severityIndex = 0;
//   List<String> safetyTips = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCrimeDetail();
//   }

//   Future<void> _loadCrimeDetail() async {
//     try {
//       final data = await api.getCrimeDetail(
//         city: widget.cityName,
//         category: widget.crimeKey,
//       );

//       setState(() {
//         incidentsCount = data["incidents_count"] ?? 0;
//         severityIndex = data["severity_index"] ?? 0;
//         safetyTips = List<String>.from(data["safety_tips"] ?? []);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2209B4),
//         title: Text(
//           "${widget.crimeTitle} in ${widget.cityName}",
//           style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : error != null
//             ? Center(
//                 child: Text(
//                   error!,
//                   style: GoogleFonts.poppins(color: Colors.red),
//                 ),
//               )
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🏙 City & Crime Summary
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE8E9FF),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "City: ${widget.cityName}",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Crime Type: ${widget.crimeTitle}",
//                           style: GoogleFonts.poppins(fontSize: 18),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Reported Incidents: $incidentsCount",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             color: Colors.redAccent,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Crime Severity Index: $severityIndex%",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             color: Colors.deepOrange,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 25),

//                   // 💡 Safety Tips
//                   Text(
//                     "Safety Tips:",
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF2209B4),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   Expanded(
//                     child: safetyTips.isEmpty
//                         ? Center(
//                             child: Text(
//                               "No safety tips available.",
//                               style: GoogleFonts.poppins(),
//                             ),
//                           )
//                         : ListView.builder(
//                             itemCount: safetyTips.length,
//                             itemBuilder: (context, index) {
//                               return Card(
//                                 elevation: 2,
//                                 margin: const EdgeInsets.symmetric(vertical: 6),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: ListTile(
//                                   leading: const Icon(
//                                     Icons.check_circle_outline,
//                                     color: Colors.green,
//                                   ),
//                                   title: Text(
//                                     safetyTips[index],
//                                     style: GoogleFonts.poppins(fontSize: 16),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../services/api_service.dart';

// class CrimeDetailScreen extends StatefulWidget {
//   final String cityName;
//   final String crimeTitle;
//   final String crimeKey;

//   const CrimeDetailScreen({
//     super.key,
//     required this.cityName,
//     required this.crimeTitle,
//     required this.crimeKey,
//   });

//   @override
//   State<CrimeDetailScreen> createState() => _CrimeDetailScreenState();
// }

// class _CrimeDetailScreenState extends State<CrimeDetailScreen> {
//   final ApiService api = ApiService();

//   bool isLoading = true;
//   String? error;

//   int incidentsCount = 0;
//   int severityIndex = 0;
//   int crimeRate = 0;
//   List<String> safetyTips = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCrimeDetail();
//   }

//   Future<void> _loadCrimeDetail() async {
//     try {
//       // 🔹 POST call to backend for city & category
//       final data = await api.getCrimeDetail(
//         city: widget.cityName,
//         category: widget.crimeKey,
//       );

//       setState(() {
//         incidentsCount = data["incidents_count"] ?? 0;
//         severityIndex = data["severity_index"] ?? 0;
//         crimeRate = data["crime_rate"] ?? 0;
//         safetyTips = List<String>.from(data["safety_tips"] ?? []);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2209B4),
//         title: Text(
//           "${widget.crimeTitle} in ${widget.cityName}",
//           style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : error != null
//             ? Center(
//                 child: Text(
//                   error!,
//                   style: GoogleFonts.poppins(color: Colors.red),
//                 ),
//               )
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🏙 City & Crime Summary
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE8E9FF),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "City: ${widget.cityName}",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Crime Type: ${widget.crimeTitle}",
//                           style: GoogleFonts.poppins(fontSize: 18),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Reported Incidents: $incidentsCount",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             color: Colors.redAccent,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Crime Severity Index: $severityIndex%",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             color: Colors.deepOrange,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Crime Rate: $crimeRate%",
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             color: Colors.blueAccent,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 25),

//                   // 💡 Safety Tips
//                   Text(
//                     "Safety Tips:",
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF2209B4),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   Expanded(
//                     child: safetyTips.isEmpty
//                         ? Center(
//                             child: Text(
//                               "No safety tips available.",
//                               style: GoogleFonts.poppins(),
//                             ),
//                           )
//                         : ListView.builder(
//                             itemCount: safetyTips.length,
//                             itemBuilder: (context, index) {
//                               return Card(
//                                 elevation: 2,
//                                 margin: const EdgeInsets.symmetric(vertical: 6),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: ListTile(
//                                   leading: const Icon(
//                                     Icons.check_circle_outline,
//                                     color: Colors.green,
//                                   ),
//                                   title: Text(
//                                     safetyTips[index],
//                                     style: GoogleFonts.poppins(fontSize: 16),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
