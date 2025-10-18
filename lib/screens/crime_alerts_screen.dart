import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrimeAlertsScreen extends StatelessWidget {
  final String city;
  final String crimeLevel;
  final List<Map<String, dynamic>> recentSearches;

  const CrimeAlertsScreen({
    super.key,
    required this.city,
    required this.crimeLevel,
    required this.recentSearches,
  });

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

  List<String> getSafetyTips(String level) {
    switch (level) {
      case 'High':
        return [
          'Avoid walking alone after dark.',
          'Stay in well-lit public areas.',
          'Keep emergency contacts handy.',
        ];
      case 'Medium':
        return [
          'Stay alert and aware of surroundings.',
          'Avoid isolated locations at night.',
        ];
      case 'Low':
        return [
          'Maintain regular safety habits.',
          'Report any suspicious activity.',
        ];
      default:
        return ['Stay cautious and informed.'];
    }
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final color = getLevelColor(crimeLevel);
    final tips = getSafetyTips(crimeLevel);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crime Alerts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF3F51B5),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Last Search Result',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text('2 min ago', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_rounded, color: color, size: 40),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  city,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${crimeLevel.toUpperCase()} RISK',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: color,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Crime Level: $crimeLevel',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Updated: Now',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety Recommendations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...tips.map((t) => Text('• $t')).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickAction(
                  context,
                  Icons.search,
                  'Search',
                  () => _showSearchDialog(context),
                ),
                _quickAction(
                  context,
                  Icons.phone,
                  'Emergency',
                  () => _showEmergencySheet(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (recentSearches.isEmpty)
              const Text(
                'No recent searches yet.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                children: recentSearches.map((item) {
                  final time = item['time'] ?? DateTime.now();
                  final level = item['level'] ?? 'Low';
                  final city = item['city'] ?? 'Unknown';
                  return _recentSearch(
                    city,
                    level,
                    timeAgo(time),
                    getLevelColor(level),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF3F51B5)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Beginner Tip\nThis screen displays your last searched city result with safety recommendations. Search for different cities to get updated crime rate information.',
                      style: TextStyle(color: Colors.black87),
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

  // ===== Quick Action Widget =====
  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey.shade800, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ===== Emergency Sheet =====
  void _showEmergencySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.local_police, color: Colors.blue),
              title: Text('Police'),
              trailing: Text('15'),
            ),
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.green),
              title: Text('Ambulance'),
              trailing: Text('1122'),
            ),
            ListTile(
              leading: Icon(Icons.fire_truck, color: Colors.orange),
              title: Text('Fire Brigade'),
              trailing: Text('16'),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Search Dialog with API =====
  void _showSearchDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Search City'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter city name...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final query = controller.text.trim();
              if (query.isNotEmpty) {
                Navigator.pop(context);
                String crimeLevel = await fetchCrimeLevel(query);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CrimeAlertsScreen(
                      city: query,
                      crimeLevel: crimeLevel,
                      recentSearches: [
                        {
                          'city': city,
                          'level': crimeLevel,
                          'time': DateTime.now(),
                        },
                        ...recentSearches,
                      ],
                    ),
                  ),
                );
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // ===== API Call Function =====
  Future<String> fetchCrimeLevel(String city) async {
    try {
      // Replace with your actual API endpoint
      final url = Uri.parse('http://127.0.0.1:9106/getCrime?city=$city');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['crimeLevel'] ?? 'Low';
      } else {
        return 'Low';
      }
    } catch (e) {
      print('API Error: $e');
      return 'Low';
    }
  }

  // ===== Recent Search Widget =====
  Widget _recentSearch(String city, String level, String time, Color dotColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: dotColor),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Crime Level: $level',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          Text(time, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
