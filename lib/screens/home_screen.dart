import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _crimeLevel;
  List<Map<String, String>> recentSearches = [
    // sample initial entries if you like
    // {'city': 'Karachi', 'level': 'High'},
    // {'city': 'Lahore', 'level': 'Medium'},
    // {'city': 'Islamabad', 'level': 'Low'},
  ];

  Future<void> fetchCrimeRate(String city) async {
    if (city.isEmpty) return;

    final url = Uri.parse('https://api.api-ninjas.com/v1/crime?city=$city');
    const apiKey = 'YOUR_API_KEY'; // Replace with your real key

    try {
      final response = await http.get(url, headers: {'X-Api-Key': apiKey});
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          // Try some logic: look for fields like “violent_crime” or “total_crime”
          // For example, if API returns something like data[0]['incidents'] or 'violent_crime' etc.
          double index;

          // Example logic: if the API returns a field "violent_crime"
          if (data[0].containsKey('violent_crime')) {
            index = double.tryParse(data[0]['violent_crime'].toString()) ?? 0;
          } else if (data[0].containsKey('total_incidents')) {
            index = double.tryParse(data[0]['total_incidents'].toString()) ?? 0;
          } else {
            // fallback to some default or other known numeric field
            index = (data[0]['crime_index'] ?? 0).toDouble();
          }

          String level = index > 50
              ? 'High'
              : index > 20
              ? 'Medium'
              : 'Low';

          setState(() {
            _crimeLevel = level;
            recentSearches.insert(0, {'city': city, 'level': level});
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('API error: $e');
    }

    // fallback if API fails
    setState(() {
      _crimeLevel = 'Medium';
      recentSearches.insert(0, {'city': city, 'level': 'Medium'});
    });
  }

  Color getLevelColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottom navigation / fixed bar
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: const Color(0xFF2209B4),
              onPressed: () {
                // maybe navigate home
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              color: Colors.grey,
              onPressed: () {
                // go to alerts
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌟 Top Bar (full width)
              Container(
                width: double.infinity,
                height: 80,
                color: const Color(0xFF2209B4),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield, color: Color(0xFF2209B4)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Crime Rate Alert",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔍 Search Bar with button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E7E7),
                          border: Border.all(color: const Color(0xFFE9E7E7)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter City Name",
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          fetchCrimeRate(_controller.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2209B4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          "Search",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Crime Level Output (if exists)
              if (_crimeLevel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Crime Level: ",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getLevelColor(_crimeLevel!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: getLevelColor(_crimeLevel!),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _crimeLevel!,
                              style: GoogleFonts.poppins(
                                color: getLevelColor(_crimeLevel!),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Quick Access
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Quick Access",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildQuickBox("Crime Categories", Icons.list),
                    buildQuickBox("Alerts", Icons.warning_amber_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildQuickBox("Safety Tips", Icons.verified_user),
                    buildQuickBox("Settings", Icons.settings),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Recent Searches
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Recent Searches",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: recentSearches.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: buildSearchTile(
                        item['city']!,
                        item['level'] ?? 'Medium',
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 100), // leave space before bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuickBox(String title, IconData icon) {
    return Container(
      height: 100,
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF4B1CF3), Color(0xFF2488DA)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchTile(String city, String level) {
    Color lvlColor = getLevelColor(level);
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE9E7E7)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black54),
                const SizedBox(width: 10),
                Text(
                  city,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: lvlColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: lvlColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    level,
                    style: GoogleFonts.poppins(
                      color: lvlColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
