import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CrimeDetailScreen extends StatefulWidget {
  final String cityName;
  final String crimeKey; // e.g. 'theft'
  final String crimeTitle; // e.g. 'Theft'
  final int localCount; // sample count from local dataset

  const CrimeDetailScreen({
    super.key,
    required this.cityName,
    required this.crimeKey,
    required this.crimeTitle,
    required this.localCount,
  });

  @override
  State<CrimeDetailScreen> createState() => _CrimeDetailScreenState();
}

class _CrimeDetailScreenState extends State<CrimeDetailScreen> {
  bool loading = true;
  String? error;
  List<dynamic> articles = [];

  // Put your NewsAPI key here
  static const String NEWS_API_KEY = 'YOUR_NEWSAPI_KEY';

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      loading = true;
      error = null;
      articles = [];
    });

    final query = Uri.encodeComponent(
      '${widget.crimeTitle} in ${widget.cityName}',
    );
    final uri = Uri.parse(
      'https://newsapi.org/v2/everything?q=$query&language=en&sortBy=publishedAt&pageSize=10&apiKey=$NEWS_API_KEY',
    );

    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body);
        if (j != null && j['articles'] != null) {
          setState(() {
            articles = (j['articles'] as List).take(10).toList();
            loading = false;
          });
        } else {
          setState(() {
            error = 'No news found';
            loading = false;
          });
        }
      } else {
        setState(() {
          error = 'News API error: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Request failed: $e';
        loading = false;
      });
    }
  }

  String severityLabel(int count) {
    if (count > 1000) return 'Very High';
    if (count > 500) return 'High';
    if (count > 200) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.localCount;
    final severity = severityLabel(count);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.crimeTitle} • ${widget.cityName}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // top summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.crimeTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Estimated incidents: $count',
                        style: GoogleFonts.poppins(color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: severity == 'High' || severity == 'Very High'
                              ? Colors.red.withOpacity(0.12)
                              : Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          severity,
                          style: GoogleFonts.poppins(
                            color: severity == 'High' || severity == 'Very High'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.report, color: const Color(0xFF2209B4), size: 36),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // safety tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety Tips',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Stay in well-lit areas\n• Keep valuables secure\n• Report suspicious behavior to police',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // News / incidents list header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent incidents / news',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            // news results
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(child: Text(error!, style: GoogleFonts.poppins()))
                  : articles.isEmpty
                  ? Center(
                      child: Text(
                        'No recent news/incidents found for this crime in ${widget.cityName}',
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: articles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final a = articles[idx] as Map<String, dynamic>;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: a['urlToImage'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      a['urlToImage'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            title: Text(
                              a['title'] ?? 'No title',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              a['source']?['name'] ?? '',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            onTap: () {
                              // open article url in browser if needed (requires url_launcher)
                            },
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
