import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> recentSearches = [];
  String? selectedLevel;

  void _performSearch() {
    if (_searchController.text.isEmpty) return;

    // Randomly assign a crime level
    final levels = ['High', 'Medium', 'Low'];
    final randomLevel = (levels..shuffle()).first;

    final search = {
      'city': _searchController.text,
      'level': randomLevel,
      'time': DateTime.now(),
    };

    setState(() {
      selectedLevel = randomLevel;
      recentSearches.insert(0, search);
    });
  }

  void _openAlertsScreen() {
    if (recentSearches.isEmpty) return;

    final last = recentSearches.first;
    Navigator.pushNamed(
      context,
      '/crime_alerts_screen',
      arguments: {
        'city': last['city'],
        'crimeLevel': last['level'],
        'recentSearches': recentSearches,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crime Rate Alert'),
        backgroundColor: const Color(0xFF3F51B5),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _openAlertsScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search City Crime Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter city name...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Show current result
            if (selectedLevel != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Crime Level: $selectedLevel',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            const Text(
              'Recent Searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: recentSearches.length,
                itemBuilder: (context, index) {
                  final item = recentSearches[index];
                  return ListTile(
                    leading: Icon(
                      Icons.location_city,
                      color: Colors.blue.shade700,
                    ),
                    title: Text(item['city']),
                    subtitle: Text('Crime Level: ${item['level']}'),
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
