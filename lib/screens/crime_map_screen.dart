import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../app_text.dart';

class CrimeMapScreen extends StatefulWidget {
  const CrimeMapScreen({super.key});

  @override
  State<CrimeMapScreen> createState() => _CrimeMapScreenState();
}

class _CrimeMapScreenState extends State<CrimeMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _api = ApiService();
  final MapController _mapController = MapController();

  static const LatLng _defaultCenter = LatLng(30.3753, 69.3451); // Pakistan
  static const double _defaultZoom = 5.2;

  bool _loading = false;

  // saari cities (default markers ke liye)
  List<Map<String, dynamic>> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadAllCities();
  }

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
  // LOAD ALL CITIES (default markers)
  // =====================================================
  Future<void> _loadAllCities() async {
    try {
      final cities = await _api.getAllCities();
      setState(() => _cities = cities);
    } catch (e) {
      debugPrint("Load cities error: $e");
    }
  }

  // =====================================================
  // SEARCH CITY
  // =====================================================
  Future<void> _searchCity() async {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final result = await _api.getCityCrimeLevel(city);

      final lat = result["lat"];
      final lng = result["lng"];
      final level = (result["crime_level"] ?? "Low").toString();
      final matchedCity = (result["matched_city"] ?? city).toString();
      final index = result["crime_index"];

      if (lat == null || lng == null) {
        _showMsg("'$matchedCity' ka map data available nahi");
      } else {
        final loc = LatLng((lat as num).toDouble(), (lng as num).toDouble());
        _mapController.move(loc, 11);
        _showCrimeBanner(matchedCity, level, index);
      }
    } catch (e) {
      _showMsg("City not found ya server error");
      debugPrint("Search error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // =====================================================
  // CRIME BANNER (floating snackbar)
  // =====================================================
  void _showCrimeBanner(String city, String level, dynamic index) {
    final color = _crimeColor(level);
    final lvl = level.toLowerCase();
    final icon = lvl == 'high'
        ? '🔴'
        : lvl == 'medium'
        ? '🟡'
        : '🟢';
    final idxText = index == null ? "" : "  •  Index: $index/100";

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
                    "Crime Level: ${level.toUpperCase()}$idxText",
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

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // =====================================================
  // MARKERS
  // =====================================================
  List<Marker> _buildMarkers() {
    return _cities.where((c) => c["lat"] != null && c["lng"] != null).map((c) {
      final lat = (c["lat"] as num).toDouble();
      final lng = (c["lng"] as num).toDouble();
      final level = (c["crime_level"] ?? "Low").toString();
      final city = (c["city"] ?? "").toString();
      final color = _crimeColor(level);

      return Marker(
        point: LatLng(lat, lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showCrimeBanner(city, level, c["crime_index"]),
          child: Icon(Icons.location_on, color: color, size: 36),
        ),
      );
    }).toList();
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.crimeMap),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                _legendDot(Colors.red, t.high),
                const SizedBox(width: 8),
                _legendDot(Colors.orange, t.medium),
                const SizedBox(width: 8),
                _legendDot(const Color(0xFF2EC4B6), t.low),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
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
                    decoration: InputDecoration(
                      hintText: t.enterCity,
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

          // MAP
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: _defaultZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.example.crime_app",
                ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
