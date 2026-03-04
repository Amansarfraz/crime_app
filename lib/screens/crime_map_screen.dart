// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// class CrimeMapScreen extends StatefulWidget {
//   const CrimeMapScreen({super.key});

//   @override
//   State<CrimeMapScreen> createState() => _CrimeMapScreenState();
// }

// class _CrimeMapScreenState extends State<CrimeMapScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   GoogleMapController? _mapController;

//   final LatLng _defaultCenter = const LatLng(30.3753, 69.3451); // Pakistan

//   bool _loading = false;

//   /// HEATMAP CIRCLES
//   Set<Circle> _heatCircles = {};

//   // =====================================================
//   // GET CITY LAT LNG
//   // =====================================================
//   Future<LatLng?> _getLatLngFromCity(String city) async {
//     try {
//       final url = Uri.parse(
//         "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(city)}&format=json&limit=1",
//       );

//       final response = await http.get(
//         url,
//         headers: {"User-Agent": "crime-app"},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data.isNotEmpty) {
//           return LatLng(
//             double.parse(data[0]["lat"]),
//             double.parse(data[0]["lon"]),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint("Location Error: $e");
//     }

//     return null;
//   }

//   // =====================================================
//   // LOAD HEATMAP FROM FASTAPI
//   // =====================================================
//   Future<void> _loadHeatmap(String city) async {
//     try {
//       final response = await http.get(
//         Uri.parse("http://127.0.0.1:8000/map/heatmap/$city"),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         Set<Circle> circles = {};

//         for (var item in data) {
//           double intensity = (item["weight"] as num).toDouble();

//           intensity = intensity.clamp(0.2, 1.0);

//           circles.add(
//             Circle(
//               circleId: CircleId("${item["lat"]}-${item["lng"]}"),

//               center: LatLng(item["lat"], item["lng"]),

//               /// HEAT SIZE
//               radius: 400 + (intensity * 700),

//               /// HEAT COLOR
//               fillColor: Colors.red.withOpacity(
//                 (0.25 + intensity).clamp(0.3, 0.9),
//               ),

//               strokeWidth: 0,
//             ),
//           );
//         }

//         setState(() {
//           _heatCircles = circles;
//         });
//       } else {
//         debugPrint("Heatmap API Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Heatmap Load Error: $e");
//     }
//   }

//   // =====================================================
//   // SEARCH CITY
//   // =====================================================
//   Future<void> _searchCity() async {
//     final city = _searchController.text.trim();

//     if (city.isEmpty) return;

//     setState(() => _loading = true);

//     final location = await _getLatLngFromCity(city);

//     if (location == null) {
//       _showMsg("City not found");
//       setState(() => _loading = false);
//       return;
//     }

//     /// MOVE CAMERA
//     _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 12));

//     /// LOAD HEATMAP
//     await _loadHeatmap(city);

//     setState(() => _loading = false);
//   }

//   void _showMsg(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   // =====================================================
//   // UI
//   // =====================================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Crime Map Heatmap"),
//         backgroundColor: Colors.indigo,
//         centerTitle: true,
//       ),

//       body: Column(
//         children: [
//           /// SEARCH BAR
//           Container(
//             margin: const EdgeInsets.all(12),
//             padding: const EdgeInsets.symmetric(horizontal: 12),

//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: const [
//                 BoxShadow(color: Colors.black12, blurRadius: 5),
//               ],
//             ),

//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: "Enter city name...",
//                       border: InputBorder.none,
//                     ),
//                     onSubmitted: (_) => _searchCity(),
//                   ),
//                 ),

//                 _loading
//                     ? const SizedBox(
//                         width: 22,
//                         height: 22,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : IconButton(
//                         icon: const Icon(Icons.search),
//                         onPressed: _searchCity,
//                       ),
//               ],
//             ),
//           ),

//           /// GOOGLE MAP
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _defaultCenter,
//                 zoom: 5,
//               ),

//               myLocationEnabled: true,
//               zoomControlsEnabled: true,

//               /// 🔥 HEATMAP HERE
//               circles: _heatCircles,

//               onMapCreated: (controller) {
//                 _mapController = controller;
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class CrimeMapScreen extends StatefulWidget {
  const CrimeMapScreen({super.key});

  @override
  State<CrimeMapScreen> createState() => _CrimeMapScreenState();
}

class _CrimeMapScreenState extends State<CrimeMapScreen> {
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;

  final LatLng _defaultCenter = const LatLng(30.3753, 69.3451); // Pakistan

  bool _loading = false;

  /// HEATMAP CIRCLES
  Set<Circle> _heatCircles = {};

  // =====================================================
  // CRIME LEVEL COLOR
  // =====================================================
  Color _crimeColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return const Color(0xFF2EC4B6); // teal/green
      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // GET CITY LAT LNG
  // =====================================================
  Future<LatLng?> _getLatLngFromCity(String city) async {
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(city)}&format=json&limit=1",
      );

      final response = await http.get(
        url,
        headers: {"User-Agent": "crime-app"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          return LatLng(
            double.parse(data[0]["lat"]),
            double.parse(data[0]["lon"]),
          );
        }
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    }

    return null;
  }

  // =====================================================
  // LOAD HEATMAP FROM FASTAPI
  // =====================================================
  Future<void> _loadHeatmap(String city, LatLng cityLocation) async {
    try {
      // ─── Pehle city ka crime level FastAPI se lo ───
      final cityRes = await http.get(
        Uri.parse("http://10.0.2.2:8000/city/${Uri.encodeComponent(city)}"),
      );

      String crimeLevel = 'medium'; // default
      int rangeKm = 25; // default radius

      if (cityRes.statusCode == 200) {
        final cityData = jsonDecode(cityRes.body);
        if (!cityData.containsKey('error')) {
          crimeLevel = cityData['crime_level'] ?? 'medium';
          rangeKm = cityData['heatmap_range_km'] ?? 25;
        }
      }

      // ─── Heatmap points FastAPI se lo (agar endpoint hai) ───
      Set<Circle> circles = {};

      final heatRes = await http.get(
        Uri.parse(
          "http://10.0.2.2:8000/map/heatmap/${Uri.encodeComponent(city)}",
        ),
      );

      if (heatRes.statusCode == 200) {
        // ── Agar aapka heatmap endpoint kaam kare ──
        final data = jsonDecode(heatRes.body) as List;
        final color = _crimeColor(crimeLevel);

        for (var item in data) {
          double intensity = (item["weight"] as num).toDouble().clamp(0.2, 1.0);

          circles.add(
            Circle(
              circleId: CircleId("${item["lat"]}-${item["lng"]}"),
              center: LatLng(
                (item["lat"] as num).toDouble(),
                (item["lng"] as num).toDouble(),
              ),
              radius: 400 + (intensity * 700),
              fillColor: color.withOpacity(
                (0.25 + intensity * 0.6).clamp(0.3, 0.85),
              ),
              strokeWidth: 0,
            ),
          );
        }
      } else {
        // ── Fallback: city center pe ek bari circle banao ──
        final color = _crimeColor(crimeLevel);
        final double radiusMeters = rangeKm * 1000.0;

        // outer glow
        circles.add(
          Circle(
            circleId: const CircleId("glow"),
            center: cityLocation,
            radius: radiusMeters * 1.4,
            fillColor: color.withOpacity(0.06),
            strokeWidth: 0,
          ),
        );

        // main heatmap circle
        circles.add(
          Circle(
            circleId: const CircleId("heatmap"),
            center: cityLocation,
            radius: radiusMeters,
            fillColor: color.withOpacity(0.22),
            strokeColor: color.withOpacity(0.8),
            strokeWidth: 2,
          ),
        );
      }

      setState(() => _heatCircles = circles);

      // ─── Crime level ka snackbar dikhao ───
      _showCrimeBanner(city, crimeLevel, rangeKm);
    } catch (e) {
      debugPrint("Heatmap Load Error: $e");
    }
  }

  // =====================================================
  // CRIME BANNER (top snackbar)
  // =====================================================
  void _showCrimeBanner(String city, String level, int rangeKm) {
    final color = _crimeColor(level);
    final icon = level == 'high'
        ? '🔴'
        : level == 'medium'
        ? '🟡'
        : '🟢';
    final label = level.toUpperCase();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Crime Level: $label  •  Range: $rangeKm km",
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // SEARCH CITY
  // =====================================================
  Future<void> _searchCity() async {
    final city = _searchController.text.trim();

    if (city.isEmpty) return;

    setState(() => _loading = true);

    final location = await _getLatLngFromCity(city);

    if (location == null) {
      _showMsg("City not found");
      setState(() => _loading = false);
      return;
    }

    /// MOVE CAMERA
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 10));

    /// LOAD HEATMAP (location pass karo fallback ke liye)
    await _loadHeatmap(city, location);

    setState(() => _loading = false);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crime Map Heatmap"),
        backgroundColor: Colors.indigo,
        centerTitle: true,

        // ─── Legend ───
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                _legendDot(Colors.red, "High"),
                const SizedBox(width: 8),
                _legendDot(Colors.orange, "Med"),
                const SizedBox(width: 8),
                _legendDot(const Color(0xFF2EC4B6), "Low"),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          /// SEARCH BAR
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5),
              ],
            ),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Enter city name...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _searchCity(),
                  ),
                ),

                _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchCity,
                      ),
              ],
            ),
          ),

          /// GOOGLE MAP
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _defaultCenter,
                zoom: 5,
              ),

              myLocationEnabled: true,
              zoomControlsEnabled: true,

              /// 🔥 HEATMAP HERE
              circles: _heatCircles,

              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Legend dot widget ───
  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
}
