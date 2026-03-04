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
