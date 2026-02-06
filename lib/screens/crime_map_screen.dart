// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import 'dart:convert'; // <-- JSON decode ke liye zaruri

class CrimeMapScreen extends StatefulWidget {
  const CrimeMapScreen({super.key});

  @override
  State<CrimeMapScreen> createState() => _CrimeMapScreenState();
}

class _CrimeMapScreenState extends State<CrimeMapScreen> {
  final ApiService api = ApiService();

  GoogleMapController? _mapController;

  final TextEditingController _searchController = TextEditingController();

  LatLng _defaultCenter = const LatLng(30.3753, 69.3451); // Pakistan

  Set<Marker> _markers = {};

  bool _loading = false;

  // ================== GET LAT LNG (FREE API) ==================
  Future<LatLng?> _getLatLngFromCity(String city) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?city=${Uri.encodeComponent(city)}"
      "&format=json",
    );

    final res = await http.get(url, headers: {"User-Agent": "crime-app"});

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      if (data.isNotEmpty) {
        final lat = double.tryParse(data[0]["lat"]);
        final lon = double.tryParse(data[0]["lon"]);

        if (lat != null && lon != null) {
          return LatLng(lat, lon);
        }
      }
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
          BitmapDescriptor.hueOrange,
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
      // 1️⃣ Get Location
      final location = await _getLatLngFromCity(city);

      if (location == null) {
        _showMsg("City not found!");
        return;
      }

      // 2️⃣ Get Crime Level
      final crimeData = await api.getCityCrimeLevel(city);

      final level = crimeData["crime_level"] ?? "Low";

      // 3️⃣ Create Marker
      final marker = Marker(
        markerId: MarkerId(city),
        position: location,
        icon: _getMarkerColor(level),
        infoWindow: InfoWindow(title: city, snippet: "Crime Level: $level"),
      );

      // 4️⃣ Update Map
      setState(() {
        _markers.clear();
        _markers.add(marker);
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 12));
    } catch (e) {
      _showMsg("Something went wrong!");
    }

    setState(() => _loading = false);
  }

  // ================== MESSAGE ==================
  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Crime Map"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
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
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchCity,
                      ),
              ],
            ),
          ),

          // 🗺 MAP
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _defaultCenter,
                  zoom: 5,
                ),

                markers: _markers,

                myLocationEnabled: true,

                zoomControlsEnabled: false,

                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
