import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_text.dart';

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

  String localizedLevel(AppText t, String level) {
    switch (level) {
      case 'High':
        return t.high;
      case 'Medium':
        return t.medium;
      case 'Low':
        return t.low;
      default:
        return level;
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

  Future<void> _callNumber(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Dialer error: $number")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Call error: $number")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final color = getLevelColor(crimeLevel);
    final tips = getSafetyTips(crimeLevel);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t.crimeAlerts,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF3F51B5),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.home),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: t.alerts,
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
                Text(
                  t.lastSearchResult,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                                Expanded(
                                  child: Text(
                                    city,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                    localizedLevel(t, crimeLevel),
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
                                  "${t.crimeLevel}: ${localizedLevel(t, crimeLevel)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
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
                          t.safetyRecommendations,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...tips.map(
                          (tip) => Text(
                            '• $tip',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              t.quickActions,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickAction(context, Icons.search, t.search, () {
                  Navigator.pop(context);
                }),
                _quickAction(
                  context,
                  Icons.phone,
                  t.emergency,
                  () => _showEmergencySheet(context, t),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              t.recentSearches,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (recentSearches.isEmpty)
              Text(
                t.ur ? "کوئی حالیہ تلاش نہیں" : "No recent searches yet.",
                style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
              )
            else
              Column(
                children: recentSearches.map((item) {
                  final rawTime = item['time'];
                  final time = rawTime is DateTime
                      ? rawTime
                      : DateTime.tryParse(rawTime?.toString() ?? '') ??
                            DateTime.now();
                  final level = item['level'] ?? 'Low';
                  final cityName = item['city'] ?? 'Unknown';
                  return _recentSearch(
                    cityName,
                    level,
                    timeAgo(time),
                    getLevelColor(level),
                    context,
                    t,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.white30 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isDark ? Colors.grey[850] : Colors.white,
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.grey.shade800,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencySheet(BuildContext context, AppText t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.emergencyContacts,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.tapToCall,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            _emergencyTile(
              context,
              icon: Icons.local_police,
              iconColor: Colors.blue,
              title: t.police,
              number: '15',
            ),
            _emergencyTile(
              context,
              icon: Icons.local_hospital,
              iconColor: Colors.green,
              title: t.ambulance,
              number: '1122',
            ),
            _emergencyTile(
              context,
              icon: Icons.fire_truck,
              iconColor: Colors.orange,
              title: t.fireBrigade,
              number: '16',
            ),
          ],
        ),
      ),
    );
  }

  Widget _emergencyTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String number,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(number, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          const Icon(Icons.call, color: Colors.green, size: 20),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        _callNumber(context, number);
      },
    );
  }

  Widget _recentSearch(
    String city,
    String level,
    String time,
    Color dotColor,
    BuildContext context,
    AppText t,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    "${t.crimeLevel}: ${localizedLevel(t, level)}",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
          ),
        ],
      ),
    );
  }
}
