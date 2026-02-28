// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'home_screen.dart'; // ← Import your real HomeScreen here

// class CrimeAlertsScreen extends StatelessWidget {
//   final String city;
//   final String crimeLevel;
//   final List<Map<String, dynamic>> recentSearches;

//   const CrimeAlertsScreen({
//     super.key,
//     required this.city,
//     required this.crimeLevel,
//     required this.recentSearches,
//   });

//   Color getLevelColor(String level) {
//     switch (level) {
//       case 'High':
//         return Colors.red;
//       case 'Medium':
//         return Colors.orange;
//       case 'Low':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   List<String> getSafetyTips(String level) {
//     switch (level) {
//       case 'High':
//         return [
//           'Avoid walking alone after dark.',
//           'Stay in well-lit public areas.',
//           'Keep emergency contacts handy.',
//         ];
//       case 'Medium':
//         return [
//           'Stay alert and aware of surroundings.',
//           'Avoid isolated locations at night.',
//         ];
//       case 'Low':
//         return [
//           'Maintain regular safety habits.',
//           'Report any suspicious activity.',
//         ];
//       default:
//         return ['Stay cautious and informed.'];
//     }
//   }

//   String timeAgo(DateTime time) {
//     final diff = DateTime.now().difference(time);
//     if (diff.inMinutes < 1) return 'Just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
//     if (diff.inHours < 24) return '${diff.inHours} hr ago';
//     return DateFormat('hh:mm a').format(time);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = getLevelColor(crimeLevel);
//     final tips = getSafetyTips(crimeLevel);

//     return Scaffold(
//       //backgroundColor: const Color(0xFFF9FAFB),
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF3F51B5),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Crime Alerts',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 1,
//         selectedItemColor: const Color(0xFF3F51B5),
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           if (index == 0) {
//             // Navigate to your real HomeScreen
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//             );
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Alerts',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Last Search
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Last Search Result',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 Text('2 min ago', style: TextStyle(color: Colors.grey[600])),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.warning_rounded, color: color, size: 40),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   city,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: color,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     '${crimeLevel.toUpperCase()} RISK',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.local_fire_department,
//                                   color: color,
//                                   size: 16,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Crime Level: $crimeLevel',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 const Text(
//                                   'Updated: Now',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Safety Recommendations',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: color,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ...tips.map((t) => Text('• $t')).toList(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Quick Actions
//             const Text(
//               'Quick Actions',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // ✅ Search now just opens your real HomeScreen
//                 _quickAction(context, Icons.search, 'Search', () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const HomeScreen()),
//                   );
//                 }),
//                 _quickAction(
//                   context,
//                   Icons.phone,
//                   'Emergency',
//                   () => _showEmergencySheet(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Recent Searches (unchanged)
//             const Text(
//               'Recent Searches',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),
//             if (recentSearches.isEmpty)
//               const Text(
//                 'No recent searches yet.',
//                 style: TextStyle(color: Colors.grey),
//               )
//             else
//               Column(
//                 children: recentSearches.map((item) {
//                   final time = item['time'] ?? DateTime.now();
//                   final level = item['level'] ?? 'Low';
//                   final city = item['city'] ?? 'Unknown';
//                   return _recentSearch(
//                     city,
//                     level,
//                     timeAgo(time),
//                     getLevelColor(level),
//                   );
//                 }).toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _quickAction(
//     BuildContext context,
//     IconData icon,
//     String label,
//     VoidCallback onTap,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: Colors.grey.shade800, size: 28),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             label,
//             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEmergencySheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             Text(
//               'Emergency Contacts',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.redAccent,
//               ),
//             ),
//             SizedBox(height: 12),
//             ListTile(
//               leading: Icon(Icons.local_police, color: Colors.blue),
//               title: Text('Police'),
//               trailing: Text('15'),
//             ),
//             ListTile(
//               leading: Icon(Icons.local_hospital, color: Colors.green),
//               title: Text('Ambulance'),
//               trailing: Text('1122'),
//             ),
//             ListTile(
//               leading: Icon(Icons.fire_truck, color: Colors.orange),
//               title: Text('Fire Brigade'),
//               trailing: Text('16'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _recentSearch(String city, String level, String time, Color dotColor) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.circle, size: 10, color: dotColor),
//               const SizedBox(width: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     city,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                   Text(
//                     'Crime Level: $level',
//                     style: const TextStyle(color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Text(time, style: const TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'home_screen.dart'; // ← Import your real HomeScreen here

// class CrimeAlertsScreen extends StatelessWidget {
//   final String city;
//   final String crimeLevel;
//   final List<Map<String, dynamic>> recentSearches;

//   const CrimeAlertsScreen({
//     super.key,
//     required this.city,
//     required this.crimeLevel,
//     required this.recentSearches,
//   });

//   Color getLevelColor(String level) {
//     switch (level) {
//       case 'High':
//         return Colors.red;
//       case 'Medium':
//         return Colors.orange;
//       case 'Low':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   List<String> getSafetyTips(String level) {
//     switch (level) {
//       case 'High':
//         return [
//           'Avoid walking alone after dark.',
//           'Stay in well-lit public areas.',
//           'Keep emergency contacts handy.',
//         ];
//       case 'Medium':
//         return [
//           'Stay alert and aware of surroundings.',
//           'Avoid isolated locations at night.',
//         ];
//       case 'Low':
//         return [
//           'Maintain regular safety habits.',
//           'Report any suspicious activity.',
//         ];
//       default:
//         return ['Stay cautious and informed.'];
//     }
//   }

//   String timeAgo(DateTime time) {
//     final diff = DateTime.now().difference(time);
//     if (diff.inMinutes < 1) return 'Just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
//     if (diff.inHours < 24) return '${diff.inHours} hr ago';
//     return DateFormat('hh:mm a').format(time);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final color = getLevelColor(crimeLevel);
//     final tips = getSafetyTips(crimeLevel);

//     // Dynamic colors for dark/light mode
//     final textColor = Theme.of(context).brightness == Brightness.dark
//         ? Colors.white
//         : Colors.black;
//     final subTextColor = Theme.of(context).brightness == Brightness.dark
//         ? Colors.white70
//         : Colors.black87;
//     final iconColor = Theme.of(context).brightness == Brightness.dark
//         ? Colors.lightBlueAccent
//         : color;

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF3F51B5),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Crime Alerts',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 1,
//         selectedItemColor: const Color(0xFF3F51B5),
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//             );
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Alerts',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Last Search
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Last Search Result',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: textColor,
//                   ),
//                 ),
//                 Text('2 min ago', style: TextStyle(color: subTextColor)),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.warning_rounded, color: color, size: 40),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   city,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                     color: textColor,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: color,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     '${crimeLevel.toUpperCase()} RISK',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.local_fire_department,
//                                   color: color,
//                                   size: 16,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Crime Level: $crimeLevel',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: subTextColor,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Updated: Now',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: subTextColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Safety Recommendations',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: color,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ...tips.map(
//                           (t) =>
//                               Text('• $t', style: TextStyle(color: textColor)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Quick Actions
//             Text(
//               'Quick Actions',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _quickAction(context, Icons.search, 'Search', () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const HomeScreen()),
//                   );
//                 }, textColor),
//                 _quickAction(
//                   context,
//                   Icons.phone,
//                   'Emergency',
//                   () => _showEmergencySheet(context),
//                   textColor,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Recent Searches
//             Text(
//               'Recent Searches',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 12),
//             if (recentSearches.isEmpty)
//               Text(
//                 'No recent searches yet.',
//                 style: TextStyle(color: subTextColor),
//               )
//             else
//               Column(
//                 children: recentSearches.map((item) {
//                   final time = item['time'] ?? DateTime.now();
//                   final level = item['level'] ?? 'Low';
//                   final city = item['city'] ?? 'Unknown';
//                   return _recentSearch(
//                     city,
//                     level,
//                     timeAgo(time),
//                     getLevelColor(level),
//                     textColor,
//                     subTextColor,
//                   );
//                 }).toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _quickAction(
//     BuildContext context,
//     IconData icon,
//     String label,
//     VoidCallback onTap,
//     Color textColor,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: textColor, size: 28),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: textColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEmergencySheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             Text(
//               'Emergency Contacts',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.redAccent,
//               ),
//             ),
//             SizedBox(height: 12),
//             ListTile(
//               leading: Icon(Icons.local_police, color: Colors.blue),
//               title: Text('Police'),
//               trailing: Text('15'),
//             ),
//             ListTile(
//               leading: Icon(Icons.local_hospital, color: Colors.green),
//               title: Text('Ambulance'),
//               trailing: Text('1122'),
//             ),
//             ListTile(
//               leading: Icon(Icons.fire_truck, color: Colors.orange),
//               title: Text('Fire Brigade'),
//               trailing: Text('16'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _recentSearch(
//     String city,
//     String level,
//     String time,
//     Color dotColor,
//     Color textColor,
//     Color subTextColor,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: ThemeData().scaffoldBackgroundColor,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.circle, size: 10, color: dotColor),
//               const SizedBox(width: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     city,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                       color: textColor,
//                     ),
//                   ),
//                   Text(
//                     'Crime Level: $level',
//                     style: TextStyle(color: subTextColor),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Text(time, style: TextStyle(color: subTextColor)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart'; // ← Import your real HomeScreen here

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
        title: const Text(
          'Crime Alerts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF3F51B5),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
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
            // Last Search
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
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
                        ...tips.map(
                          (t) => Text(
                            '• $t',
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

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickAction(context, Icons.search, 'Search', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }),
                _quickAction(
                  context,
                  Icons.phone,
                  'Emergency',
                  () => _showEmergencySheet(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recent Searches
            const Text(
              'Recent Searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (recentSearches.isEmpty)
              Text(
                'No recent searches yet.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
              )
            else
              Column(
                children: recentSearches.map((item) {
                  final time = item['time'] ?? DateTime.now();
                  final level = item['level'] ?? 'Low';
                  final cityName = item['city'] ?? 'Unknown';
                  return _recentSearch(
                    cityName,
                    level,
                    timeAgo(time),
                    getLevelColor(level),
                    context,
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

  Widget _recentSearch(
    String city,
    String level,
    String time,
    Color dotColor,
    BuildContext context,
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
                    'Crime Level: $level',
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
