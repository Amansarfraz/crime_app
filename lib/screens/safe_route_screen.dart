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

  static const LatLng _defaultCenter = LatLng(30.3753, 69.3451); // Pakistan

  LatLng? _start;
  LatLng? _end;
  List<LatLng> _routePoints = [];
  bool _loading = false;

  // seeded cities (danger zones)
  List<Map<String, dynamic>> _cities = [];
  // high-crime cities jo route ke paas hain
  List<Map<String, dynamic>> _warnings = [];
  int _safetyScore = 100;

  @override
  void initState() {
    super.initState();
    _loadCities();
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

  // tap pe start/end set karo
  void _onTap(TapPosition tapPos, LatLng point) {
    setState(() {
      if (_start == null) {
        _start = point;
      } else if (_end == null) {
        _end = point;
      } else {
        // dono set hain -> reset, naya start
        _start = point;
        _end = null;
        _routePoints = [];
        _warnings = [];
        _safetyScore = 100;
      }
    });
  }

  void _reset() {
    setState(() {
      _start = null;
      _end = null;
      _routePoints = [];
      _warnings = [];
      _safetyScore = 100;
    });
  }

  // haversine distance (km)
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

  // OSRM se route nikaalo
  Future<void> _findRoute() async {
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Map par start aur destination tap karein"),
        ),
      );
      return;
    }

    setState(() => _loading = true);

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
      debugPrint("Route error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // route ke paas high-crime cities dhoondo + safety score
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

      // route ke kisi bhi point se 15km ke andar?
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

    // danger zone markers (warnings)
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          // instruction banner
          Container(
            width: double.infinity,
            color: const Color(0xFF2209B4).withOpacity(0.08),
            padding: const EdgeInsets.all(12),
            child: Text(
              _start == null
                  ? "👆 Map par START point tap karein"
                  : _end == null
                  ? "👆 Ab DESTINATION tap karein"
                  : "✅ 'Find Safe Route' dabayein",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 5.2,
                    onTap: _onTap,
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

                // safety score card (route milne ke baad)
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
                                  "Safety Score: $_safetyScore/100",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  _warnings.isEmpty
                                      ? "No high-crime zones on this route 👍"
                                      : "⚠️ Passes near ${_warnings.length} high-crime area(s)",
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

          // warnings list
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

          // find route button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _findRoute,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
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
                    fontSize: 16,
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
          ),
        ],
      ),
    );
  }
}
