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
  final TextEditingController _cityCtrl =
      TextEditingController(); // sheher (Karachi)

  static const LatLng _defaultCenter = LatLng(30.3753, 69.3451); // Pakistan

  LatLng? _start;
  LatLng? _end;
  String _startName = "";
  String _endName = "";
  List<LatLng> _routePoints = [];
  bool _loading = false;

  double _distanceText = 0; // km
  double _durationText = 0; // min

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
    _cityCtrl.dispose();
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

  // area/mohalla name -> coordinates.
  // city alag likhi ho to "area, city, Pakistan" se Nominatim pe dhoondta hai.
  // warna seeded cities me match, warna "name, Pakistan".
  Future<Map<String, dynamic>?> _geocodeArea(String name) async {
    final raw = name.trim();
    final q = raw.toLowerCase();
    if (q.isEmpty) return null;

    final city = _cityCtrl.text.trim();

    // Agar user ne city field bhari hai -> seedha Nominatim (area level)
    // taake chhote area/mohalle accurate milein.
    if (city.isNotEmpty) {
      final hit = await _nominatim("$raw, $city, Pakistan");
      if (hit != null) return hit;
      // city ke sath na mile to area akela try karo
      final hit2 = await _nominatim("$raw, Pakistan");
      if (hit2 != null) return hit2;
      return null;
    }

    // city field khaali -> pehle seeded bade sheher me match (tez)
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

    // warna Nominatim fallback
    return await _nominatim("$raw, Pakistan");
  }

  Future<Map<String, dynamic>?> _nominatim(String query) async {
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?"
        "q=${Uri.encodeComponent(query)}"
        "&format=json&limit=1&countrycodes=pk",
      );
      final res = await http.get(
        url,
        headers: {"User-Agent": "crime-alert-app/1.0"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isNotEmpty) {
          final display = (data[0]["display_name"] ?? "").toString();
          final shortName = display.split(",").first.trim();
          return {
            "lat": double.parse(data[0]["lat"]),
            "lng": double.parse(data[0]["lon"]),
            "name": shortName.isEmpty ? query : shortName,
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
      _msg("Start aur destination dono likhein");
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _routePoints = [];
      _warnings = [];
      _safetyScore = 100;
      _distanceText = 0;
      _durationText = 0;
    });

    // 1) geocode dono areas
    final from = await _geocodeArea(fromName);
    final to = await _geocodeArea(toName);

    if (from == null) {
      _msg("'$fromName' nahi mila. City bhi likh ke dekhein.");
      setState(() => _loading = false);
      return;
    }
    if (to == null) {
      _msg("'$toName' nahi mila. City bhi likh ke dekhein.");
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
        final routes = data["routes"] as List?;
        if (routes == null || routes.isEmpty) {
          _msg("Is area ke beech route nahi mila");
          setState(() => _loading = false);
          return;
        }
        final r0 = routes[0];
        final coords = r0["geometry"]["coordinates"] as List;
        final points = coords
            .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
            )
            .toList();

        final dist = (r0["distance"] as num?)?.toDouble() ?? 0; // meters
        final dur = (r0["duration"] as num?)?.toDouble() ?? 0; // seconds

        setState(() {
          _routePoints = points;
          _distanceText = dist / 1000.0;
          _durationText = dur / 60.0;
        });
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
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Color _scoreColor() {
    if (_safetyScore >= 70) return Colors.green;
    if (_safetyScore >= 40) return Colors.orange;
    return Colors.red;
  }

  String _scoreLabel() {
    if (_safetyScore >= 70) return "Safe";
    if (_safetyScore >= 40) return "Moderate";
    return "Risky";
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
          // From / To / City inputs
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            child: Column(
              children: [
                _field(
                  _fromCtrl,
                  "From — area/mohalla (e.g. Baldia Town)",
                  Icons.trip_origin,
                  Colors.green,
                  isDark,
                ),
                const SizedBox(height: 8),
                _field(
                  _toCtrl,
                  "To — area/mohalla (e.g. Nazimabad)",
                  Icons.location_on,
                  Colors.blue,
                  isDark,
                ),
                const SizedBox(height: 8),
                _field(
                  _cityCtrl,
                  "City (e.g. Karachi) — accurate match ke liye",
                  Icons.location_city,
                  Colors.deepPurple,
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
                            radius: 26,
                            backgroundColor: _scoreColor().withValues(
                              alpha: 0.15,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$_safetyScore",
                                  style: GoogleFonts.poppins(
                                    color: _scoreColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  _scoreLabel(),
                                  style: GoogleFonts.poppins(
                                    color: _scoreColor(),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$_startName → $_endName",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${_distanceText.toStringAsFixed(1)} km • "
                                  "${_durationText.toStringAsFixed(0)} min",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                Text(
                                  _warnings.isEmpty
                                      ? "No high-crime zone on route 👍"
                                      : "⚠️ ${_warnings.length} high-crime zone(s)",
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
                      color: _levelColor(level).withValues(alpha: 0.1),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    Color iconColor,
    bool isDark,
  ) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white54 : Colors.grey,
        ),
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
