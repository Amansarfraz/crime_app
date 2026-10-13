import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  State<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen> {
  final ApiService _api = ApiService();
  final MapController _mapController = MapController();
  final TextEditingController _fromCtrl = TextEditingController();
  final TextEditingController _toCtrl = TextEditingController();

  static const LatLng _defaultCenter = LatLng(30.3753, 69.3451); // Pakistan

  LatLng? _start;
  LatLng? _end;
  String _startName = "";
  String _endName = "";
  List<LatLng> _routePoints = [];
  bool _loading = false;

  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _warnings = [];
  int _safetyScore = 100;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      _cities = await _api.getAllCities();
    } catch (_) {}
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // city name -> coordinates (seeded data se, warna OSM nominatim fallback)
  Future<Map<String, dynamic>?> _geocodeCity(String name) async {
    final q = name.trim().toLowerCase();
    if (q.isEmpty) return null;

    // 1) seeded cities me exact/partial match
    for (final c in _cities) {
      final cityName = (c["city"] ?? "").toString().toLowerCase();
      if (cityName == q && c["lat"] != null && c["lng"] != null) {
        return {
          "lat": (c["lat"] as num).toDouble(),
          "lng": (c["lng"] as num).toDouble(),
          "name": c["city"],
        };
      }
    }
    for (final c in _cities) {
      final cityName = (c["city"] ?? "").toString().toLowerCase();
      if (cityName.contains(q) && c["lat"] != null && c["lng"] != null) {
        return {
          "lat": (c["lat"] as num).toDouble(),
          "lng": (c["lng"] as num).toDouble(),
          "name": c["city"],
        };
      }
    }

    // 2) OSM Nominatim fallback (free) - Pakistan ke andar
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?"
        "q=${Uri.encodeComponent('$name, Pakistan')}&format=json&limit=1",
      );
      final res = await http.get(url, headers: {"User-Agent": "crime-app"});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isNotEmpty) {
          return {
            "lat": double.parse(data[0]["lat"]),
            "lng": double.parse(data[0]["lon"]),
            "name": name,
          };
        }
      }
    } catch (_) {}

    return null;
  }

  double _distanceKm(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  Future<void> _findRoute() async {
    final fromName = _fromCtrl.text.trim();
    final toName = _toCtrl.text.trim();

    if (fromName.isEmpty || toName.isEmpty) {
      _msg("Dono city ke naam likhein");
      return;
    }

    setState(() {
      _loading = true;
      _routePoints = [];
      _warnings = [];
      _safetyScore = 100;
    });

    // 1) geocode dono cities
    final from = await _geocodeCity(fromName);
    final to = await _geocodeCity(toName);

    if (from == null) {
      _msg("Start city '$fromName' nahi mila");
      setState(() => _loading = false);
      return;
    }
    if (to == null) {
      _msg("Destination '$toName' nahi mila");
      setState(() => _loading = false);
      return;
    }

    _start = LatLng(from["lat"], from["lng"]);
    _end = LatLng(to["lat"], to["lng"]);
    _startName = from["name"].toString();
    _endName = to["name"].toString();

    // 2) OSRM route
    try {
      final url = Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/"
        "${_start!.longitude},${_start!.latitude};"
        "${_end!.longitude},${_end!.latitude}"
        "?overview=full&geometries=geojson",
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final coords = data["routes"][0]["geometry"]["coordinates"] as List;
        final points = coords
            .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
            )
            .toList();
        setState(() => _routePoints = points);
        _analyzeRoute(points);
        _fitBounds();
      } else {
        _msg("Route nahi mila");
      }
    } catch (e) {
      _msg("Route error. Internet check karein");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _analyzeRoute(List<LatLng> points) {
    final warnings = <Map<String, dynamic>>[];
    int score = 100;

    for (final city in _cities) {
      if (city["lat"] == null || city["lng"] == null) continue;
      final level = (city["crime_level"] ?? "Low").toString();
      if (level == "Low") continue;

      final cityLoc = LatLng(
        (city["lat"] as num).toDouble(),
        (city["lng"] as num).toDouble(),
      );

      bool near = false;
      for (final p in points) {
        if (_distanceKm(p, cityLoc) <= 15) {
          near = true;
          break;
        }
      }
      if (near) {
        warnings.add(city);
        score -= (level == "High") ? 20 : 10;
      }
    }

    if (score < 0) score = 0;
    setState(() {
      _warnings = warnings;
      _safetyScore = score;
    });
  }

  void _fitBounds() {
    if (_routePoints.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Color _scoreColor() {
    if (_safetyScore >= 70) return Colors.green;
    if (_safetyScore >= 40) return Colors.orange;
    return Colors.red;
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    if (_start != null) {
      markers.add(
        Marker(
          point: _start!,
          width: 40,
          height: 40,
          child: const Icon(Icons.trip_origin, color: Colors.green, size: 32),
        ),
      );
    }
    if (_end != null) {
      markers.add(
        Marker(
          point: _end!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.blue, size: 36),
        ),
      );
    }
    for (final w in _warnings) {
      markers.add(
        Marker(
          point: LatLng(
            (w["lat"] as num).toDouble(),
            (w["lng"] as num).toDouble(),
          ),
          width: 36,
          height: 36,
          child: Icon(
            Icons.warning_rounded,
            color: _levelColor((w["crime_level"] ?? "Medium").toString()),
            size: 30,
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          "Safe Route",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // From / To inputs
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            child: Column(
              children: [
                _cityField(
                  _fromCtrl,
                  "From (start city)",
                  Icons.trip_origin,
                  Colors.green,
                  isDark,
                ),
                const SizedBox(height: 8),
                _cityField(
                  _toCtrl,
                  "To (destination city)",
                  Icons.location_on,
                  Colors.blue,
                  isDark,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _findRoute,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.route, color: Colors.white),
                    label: Text(
                      "Find Safe Route",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2209B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 5.2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.example.crime_app",
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5,
                            color: _scoreColor(),
                          ),
                        ],
                      ),
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ),

                if (_routePoints.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: _scoreColor().withOpacity(0.15),
                            child: Text(
                              "$_safetyScore",
                              style: GoogleFonts.poppins(
                                color: _scoreColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$_startName → $_endName",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  _warnings.isEmpty
                                      ? "Safe route 👍 (score $_safetyScore)"
                                      : "⚠️ ${_warnings.length} high-crime zone(s) on route",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: _warnings.isEmpty
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (_warnings.isNotEmpty)
            Container(
              height: 90,
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                children: _warnings.map((w) {
                  final level = (w["crime_level"] ?? "Medium").toString();
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _levelColor(level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _levelColor(level)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: _levelColor(level),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                (w["city"] ?? "").toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$level risk zone",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _levelColor(level),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cityField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    Color iconColor,
    bool isDark,
  ) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
