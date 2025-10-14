import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrimeDetailScreen extends StatefulWidget {
  const CrimeDetailScreen({super.key});

  @override
  State<CrimeDetailScreen> createState() => _CrimeDetailScreenState();
}

class _CrimeDetailScreenState extends State<CrimeDetailScreen> {
  final TextEditingController cityController = TextEditingController();
  bool loading = false;
  List<dynamic> news = [];

  Future<void> fetchCrimeData(String city) async {
    setState(() {
      loading = true;
      news.clear();
    });

    const apiKey = "YOUR_API_KEY"; // 🔑 Replace with your actual NewsAPI key
    final uri = Uri.parse(
      "https://newsapi.org/v2/everything?q=crime+$city&language=en&sortBy=publishedAt&apiKey=$apiKey",
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          news = json['articles'];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          "City Crime Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2209B4),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Search Bar
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: "Enter City Name (e.g. Lahore, Karachi)",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                prefixIcon: const Icon(
                  Icons.location_city,
                  color: Color(0xFF2209B4),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final city = cityController.text.trim();
                if (city.isNotEmpty) {
                  fetchCrimeData(city);
                }
              },
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text(
                "Search Crime Data",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2209B4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Content
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : news.isEmpty
                  ? Center(
                      child: Text(
                        "No crime data found. Try another city.",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final item = news[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item['urlToImage'] != null
                                  ? Image.network(
                                      item['urlToImage'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                            ),
                            title: Text(
                              item['title'] ?? 'No title available',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item['description'] ?? 'No details available',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
