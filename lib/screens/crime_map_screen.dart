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

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ================= API SERVICE =================
class ApiService {
  Future<Map<String, dynamic>> getCityCrimeLevel(String city) async {
    Map<String, String> dummyData = {
      "Lahore": "high",
      "Karachi": "medium",
      "Islamabad": "low",
      "Peshawar": "high",
      "Quetta": "medium",
    };

    await Future.delayed(const Duration(milliseconds: 400));

    return {"crime_level": dummyData[city] ?? "low"};
  }
}

/// ================= SCREEN =================
class CrimeMapScreen extends StatefulWidget {
  const CrimeMapScreen({super.key});

  @override
  State<CrimeMapScreen> createState() => _CrimeMapScreenState();
}

class _CrimeMapScreenState extends State<CrimeMapScreen> {
  final ApiService api = ApiService();

  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  final LatLng _defaultCenter = const LatLng(
    30.3753,
    69.3451,
  ); // Pakistan Center

  final Set<Marker> _markers = {};

  bool _loading = false;

  String _currentCity = "";
  String _currentCrimeLevel = "";

  /// ================= GET LAT LNG =================
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

  /// ================= MARKER COLOR =================
  BitmapDescriptor _getMarkerColor(String level) {
    switch (level.toLowerCase()) {
      case "high":
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

      case "medium":
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );

      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  /// ================= CARD COLOR =================
  Color _crimeColor(String level) {
    switch (level.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  /// ================= SEARCH =================
  Future<void> _searchCity() async {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;

    setState(() => _loading = true);

    try {
      final location = await _getLatLngFromCity(city);

      if (location == null) {
        _showMsg("City not found");
        setState(() => _loading = false);
        return;
      }

      final crimeData = await api.getCityCrimeLevel(city);
      final level = crimeData["crime_level"] ?? "low";

      final marker = Marker(
        markerId: MarkerId(city),
        position: location,
        icon: _getMarkerColor(level),
        infoWindow: InfoWindow(title: city, snippet: "Crime Level: $level"),
      );

      setState(() {
        _markers.clear();
        _markers.add(marker);

        _currentCity = city;
        _currentCrimeLevel = level;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 12));
    } catch (e) {
      debugPrint(e.toString());
      _showMsg("Something went wrong");
    }

    setState(() => _loading = false);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crime Map"),
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

          /// MAP + CRIME CARD
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _defaultCenter,
                    zoom: 5,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),

                /// ===== CRIME LEVEL CARD =====
                if (_currentCity.isNotEmpty)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: _crimeColor(_currentCrimeLevel),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentCity,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Crime Level: ${_currentCrimeLevel.toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _crimeColor(_currentCrimeLevel),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
