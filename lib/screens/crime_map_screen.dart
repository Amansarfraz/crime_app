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
//         infoWindow: InfoWindow(
//           title: city,
//           snippet: "Crime: ${level.toUpperCase()}",
//         ),
//       );

//       setState(() {
//         // Multiple markers supported
//         _markers.add(marker);
//       });

//       // Zoom/fit map to all markers
//       _fitMapToMarkers();
//     } catch (e) {
//       _showMsg("Something went wrong!");
//       debugPrint("Error searching city: $e");
//     }

//     setState(() => _loading = false);
//   }

//   // ================== FIT MAP TO ALL MARKERS ==================
//   void _fitMapToMarkers() {
//     if (_markers.isEmpty || _mapController == null) return;

//     double? x0, x1, y0, y1;
//     for (Marker m in _markers) {
//       if (x0 == null) {
//         x0 = x1 = m.position.latitude;
//         y0 = y1 = m.position.longitude;
//       } else {
//         if (m.position.latitude > x1!) x1 = m.position.latitude;
//         if (m.position.latitude < x0) x0 = m.position.latitude;
//         if (m.position.longitude > y1!) y1 = m.position.longitude;
//         if (m.position.longitude < y0) y0 = m.position.longitude;
//       }
//     }

//     // Use double padding to fix type error
//     LatLngBounds bounds = LatLngBounds(
//       southwest: LatLng(x0!, y0!),
//       northeast: LatLng(x1!, y1!),
//     );

//     _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
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
//           // ========== Search Box ==========
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
//           // ========== Map ==========
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
//   final LatLng _defaultCenter = const LatLng(30.3753, 69.3451);
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
//         infoWindow: InfoWindow(
//           title: city,
//           snippet: "Crime Level: ${level.toUpperCase()}",
//         ),
//       );

//       setState(() {
//         _markers.add(marker);
//       });

//       _fitMapToMarkers();
//     } catch (e) {
//       _showMsg("Something went wrong!");
//       debugPrint("Error searching city: $e");
//     }

//     setState(() => _loading = false);
//   }

//   // ================== FIT MAP TO ALL MARKERS ==================
//   void _fitMapToMarkers() {
//     if (_markers.isEmpty || _mapController == null) return;

//     // Make variables NON NULLABLE (important fix)
//     double x0 = _markers.first.position.latitude;
//     double x1 = _markers.first.position.latitude;
//     double y0 = _markers.first.position.longitude;
//     double y1 = _markers.first.position.longitude;

//     for (Marker m in _markers) {
//       if (m.position.latitude > x1) x1 = m.position.latitude;
//       if (m.position.latitude < x0) x0 = m.position.latitude;
//       if (m.position.longitude > y1) y1 = m.position.longitude;
//       if (m.position.longitude < y0) y0 = m.position.longitude;
//     }

//     LatLngBounds bounds = LatLngBounds(
//       southwest: LatLng(x0, y0),
//       northeast: LatLng(x1, y1),
//     );

//     _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
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
//           // ========== Search Box ==========
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

//           // ========== MAP ==========
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
//   final Set<Circle> _circles = {};
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

//   // ================== ADD CIRCLE ==================
//   void _addCircle(LatLng position, String level) {
//     Color color;
//     switch (level.toLowerCase()) {
//       case 'high':
//         color = Colors.red.withOpacity(0.7);
//         break;
//       case 'medium':
//         color = Colors.yellow.withOpacity(0.7);
//         break;
//       default:
//         color = Colors.green.withOpacity(0.7);
//     }

//     _circles.add(
//       Circle(
//         circleId: CircleId(position.toString()),
//         center: position,
//         radius: 400, // radius in meters
//         fillColor: color,
//         strokeColor: Colors.transparent,
//       ),
//     );
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

//       // Add marker
//       _markers.add(
//         Marker(
//           markerId: MarkerId(city),
//           position: location,
//           infoWindow: InfoWindow(
//             title: city,
//             snippet: "Crime Level: ${level.toUpperCase()}",
//           ),
//         ),
//       );

//       // Add circle
//       _addCircle(location, level);

//       setState(() {}); // refresh map

//       // Fit map to markers
//       _fitMapToMarkers();
//     } catch (e) {
//       _showMsg("Something went wrong!");
//       debugPrint("Error searching city: $e");
//     }

//     setState(() => _loading = false);
//   }

//   // ================== FIT MAP TO ALL MARKERS ==================
//   void _fitMapToMarkers() {
//     if (_markers.isEmpty || _mapController == null) return;

//     double x0 = _markers.first.position.latitude;
//     double x1 = _markers.first.position.latitude;
//     double y0 = _markers.first.position.longitude;
//     double y1 = _markers.first.position.longitude;

//     for (Marker m in _markers) {
//       if (m.position.latitude > x1) x1 = m.position.latitude;
//       if (m.position.latitude < x0) x0 = m.position.latitude;
//       if (m.position.longitude > y1) y1 = m.position.longitude;
//       if (m.position.longitude < y0) y0 = m.position.longitude;
//     }

//     LatLngBounds bounds = LatLngBounds(
//       southwest: LatLng(x0, y0),
//       northeast: LatLng(x1, y1),
//     );

//     _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80.0));
//   }

//   void _showMsg(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text("Crime Map"),
//         centerTitle: true,
//         backgroundColor: Colors.indigo,
//       ),
//       body: Column(
//         children: [
//           // ========== Search Box ==========
//           Container(
//             margin: const EdgeInsets.all(12),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: const [
//                 BoxShadow(color: Colors.black26, blurRadius: 6),
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
//                       hintStyle: TextStyle(color: Colors.grey),
//                     ),
//                     onSubmitted: (_) => _searchCity(),
//                   ),
//                 ),
//                 _loading
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : IconButton(
//                         icon: const Icon(Icons.search, color: Colors.indigo),
//                         onPressed: _searchCity,
//                       ),
//               ],
//             ),
//           ),

//           // ========== MAP ==========
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _defaultCenter,
//                 zoom: 5,
//               ),
//               markers: _markers,
//               circles: _circles,
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

class ApiService {
  Future<Map<String, dynamic>> getCityCrimeLevel(String city) async {
    Map<String, String> dummyData = {
      "Lahore": "high",
      "Karachi": "medium",
      "Islamabad": "low",
      "Peshawar": "high",
      "Quetta": "medium",
    };
    await Future.delayed(const Duration(milliseconds: 300));
    return {"crime_level": dummyData[city] ?? "low"};
  }
}

class CrimeMapScreen extends StatefulWidget {
  const CrimeMapScreen({super.key});

  @override
  State<CrimeMapScreen> createState() => _CrimeMapScreenState();
}

class _CrimeMapScreenState extends State<CrimeMapScreen> {
  final ApiService api = ApiService();
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final LatLng _defaultCenter = const LatLng(30.3753, 69.3451); // Pakistan
  final Set<Marker> _markers = {};
  bool _loading = false;

  // ================== GET LAT LNG ==================
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
      debugPrint("Error fetching city location: $e");
    }
    return null;
  }

  // ================== MARKER COLOR ==================
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

  // ================== SEARCH CITY ==================
  Future<void> _searchCity() async {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;

    setState(() => _loading = true);

    try {
      final location = await _getLatLngFromCity(city);
      if (location == null) {
        _showMsg("City not found!");
        setState(() => _loading = false);
        return;
      }

      final crimeData = await api.getCityCrimeLevel(city);
      final level = crimeData["crime_level"]?.toString() ?? "low";

      final marker = Marker(
        markerId: MarkerId(city),
        position: location,
        icon: _getMarkerColor(level),
        infoWindow: InfoWindow(title: city, snippet: "Crime Level: $level"),
      );

      setState(() {
        _markers.clear();
        _markers.add(marker);
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 12));
    } catch (e) {
      _showMsg("Something went wrong!");
      debugPrint("Error searching city: $e");
    }

    setState(() => _loading = false);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crime Map"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
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
          Expanded(
            child: GoogleMap(
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
          ),
        ],
      ),
    );
  }
}
