// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ApiService {
//   Future<Map<String, dynamic>> getCityCrimeLevel(String city) async {
//     Map<String, String> dummyData = {
//       "Lahore": "high",
//       "Karachi": "medium",
//       "Islamabad": "low",
//       "Peshawar": "high",
//       "Quetta": "medium",
//     };
//     await Future.delayed(const Duration(milliseconds: 300));
//     return {"crime_level": dummyData[city] ?? "low"};
//   }
// }

// class CrimeMapScreen extends StatefulWidget {
//   const CrimeMapScreen({super.key});

//   @override
//   State<CrimeMapScreen> createState() => _CrimeMapScreenState();
// }

// class _CrimeMapScreenState extends State<CrimeMapScreen> {
//   final ApiService api = ApiService();
//   GoogleMapController? _mapController;
//   final TextEditingController _searchController = TextEditingController();
//   final LatLng _defaultCenter = const LatLng(30.3753, 69.3451); // Pakistan
//   final Set<Marker> _markers = {};
//   bool _loading = false;

//   // ================== GET LAT LNG ==================
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
//       debugPrint("Error fetching city location: $e");
//     }
//     return null;
//   }

//   // ================== MARKER COLOR ==================
//   BitmapDescriptor _getMarkerColor(String level) {
//     switch (level.toLowerCase()) {
//       case "high":
//         return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//       case "medium":
//         return BitmapDescriptor.defaultMarkerWithHue(
//           BitmapDescriptor.hueYellow,
//         );
//       default:
//         return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//     }
//   }

//   // ================== SEARCH CITY ==================
//   Future<void> _searchCity() async {
//     final city = _searchController.text.trim();
//     if (city.isEmpty) return;

//     setState(() => _loading = true);

//     try {
//       final location = await _getLatLngFromCity(city);
//       if (location == null) {
//         _showMsg("City not found!");
//         setState(() => _loading = false);
//         return;
//       }

//       final crimeData = await api.getCityCrimeLevel(city);
//       final level = crimeData["crime_level"]?.toString() ?? "low";

//       final marker = Marker(
//         markerId: MarkerId(city),
//         position: location,
//         icon: _getMarkerColor(level),
//         infoWindow: InfoWindow(title: city, snippet: "Crime Level: $level"),
//       );

//       setState(() {
//         _markers.clear();
//         _markers.add(marker);
//       });

//       _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 12));
//     } catch (e) {
//       _showMsg("Something went wrong!");
//       debugPrint("Error searching city: $e");
//     }

//     setState(() => _loading = false);
//   }

//   void _showMsg(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Crime Map"),
//         centerTitle: true,
//         backgroundColor: Colors.indigo,
//       ),
//       body: Column(
//         children: [
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
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _defaultCenter,
//                 zoom: 5,
//               ),
//               markers: _markers,
//               myLocationEnabled: true,
//               zoomControlsEnabled: true,
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
//   final LatLng _defaultCenter = const LatLng(
//     30.3753,
//     69.3451,
//   ); // Pakistan center
//   bool _loading = false;

//   Set<Circle> _heatCircles = {};

//   /// ================== GET LAT LNG ==================
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

//   /// ================== LOAD HEATMAP FROM BACKEND ==================
//   Future<void> _loadHeatmap(String city) async {
//     try {
//       final response = await http.get(
//         Uri.parse("http://127.0.0.1:8000/map/heatmap/karachi"),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         Set<Circle> circles = {};

//         for (var item in data) {
//           double intensity = (item["weight"] as num).toDouble();
//           // Clamp intensity between 0.2 and 0.9 for visibility
//           intensity = intensity.clamp(0.2, 0.9);

//           circles.add(
//             Circle(
//               circleId: CircleId('${item["lat"]}-${item["lng"]}'),
//               center: LatLng(item["lat"], item["lng"]),
//               radius: 200, // meters
//               fillColor: Colors.red.withOpacity(intensity),
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

//   /// ================== SEARCH CITY ==================
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

//     // Move camera to city
//     _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 12));

//     // Load backend heatmap
//     await _loadHeatmap(city);

//     setState(() => _loading = false);
//   }

//   void _showMsg(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   /// ================== UI ==================
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
//           // ===== SEARCH BAR =====
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

//           // ===== GOOGLE MAP WITH HEATMAP =====
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _defaultCenter,
//                 zoom: 5,
//               ),
//               myLocationEnabled: true,
//               zoomControlsEnabled: true,
//               circles: _heatCircles, // <-- replaced heatmaps with circles
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
  Future<void> _loadHeatmap(String city) async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/map/heatmap/$city"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Set<Circle> circles = {};

        for (var item in data) {
          double intensity = (item["weight"] as num).toDouble();

          intensity = intensity.clamp(0.2, 1.0);

          circles.add(
            Circle(
              circleId: CircleId("${item["lat"]}-${item["lng"]}"),

              center: LatLng(item["lat"], item["lng"]),

              /// HEAT SIZE
              radius: 400 + (intensity * 700),

              /// HEAT COLOR
              fillColor: Colors.red.withOpacity(
                (0.25 + intensity).clamp(0.3, 0.9),
              ),

              strokeWidth: 0,
            ),
          );
        }

        setState(() {
          _heatCircles = circles;
        });
      } else {
        debugPrint("Heatmap API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Heatmap Load Error: $e");
    }
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
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 12));

    /// LOAD HEATMAP
    await _loadHeatmap(city);

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
}
