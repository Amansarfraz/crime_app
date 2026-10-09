import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../app_text.dart';
import 'report_incident_screen.dart';

class IncidentFeedScreen extends StatefulWidget {
  const IncidentFeedScreen({super.key});

  @override
  State<IncidentFeedScreen> createState() => _IncidentFeedScreenState();
}

class _IncidentFeedScreenState extends State<IncidentFeedScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  List<Map<String, dynamic>> _incidents = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String? city}) async {
    setState(() => _loading = true);
    try {
      _incidents = await _api.getIncidentFeed(city: city);
    } catch (_) {
      _incidents = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  IconData _catIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'theft':
        return Icons.lock_open;
      case 'robbery':
        return Icons.remove_red_eye;
      case 'harassment':
        return Icons.warning_amber_rounded;
      case 'assault':
        return Icons.gavel;
      case 'cybercrime':
        return Icons.computer;
      case 'fraud':
        return Icons.credit_card;
      case 'vandalism':
        return Icons.brush;
      case 'suspicious activity':
        return Icons.visibility;
      default:
        return Icons.report_problem;
    }
  }

  String _timeAgo(String iso) {
    final time = DateTime.tryParse(iso);
    if (time == null) return "";
    final diff = DateTime.now().toUtc().difference(time);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return DateFormat("d MMM").format(time.toLocal());
  }

  Future<void> _openReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
    );
    if (result == true) _load(); // refresh after new report
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppText.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          t.ur ? "کمیونٹی رپورٹس" : "Community Reports",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _load(city: _searchCtrl.text),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2209B4),
        onPressed: _openReport,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          t.ur ? "رپورٹ" : "Report",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              onSubmitted: (v) => _load(city: v),
              decoration: InputDecoration(
                hintText: t.ur ? "شہر سے فلٹر کریں..." : "Filter by city...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                        },
                      )
                    : null,
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _incidents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 60,
                          color: isDark ? Colors.white30 : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.ur
                              ? "ابھی کوئی رپورٹ نہیں۔ پہلے بنیں!"
                              : "No reports yet. Be the first!",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _load(city: _searchCtrl.text),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _incidents.length,
                      itemBuilder: (context, i) {
                        final inc = _incidents[i];
                        final cat = (inc["category"] ?? "").toString();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade900 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(
                                      0xFF2209B4,
                                    ).withOpacity(0.12),
                                    child: Icon(
                                      _catIcon(cat),
                                      color: const Color(0xFF2209B4),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 13,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              (inc["city"] ?? "").toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _timeAgo((inc["time"] ?? "").toString()),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (inc["description"] ?? "").toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  height: 1.4,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 13,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (inc["reporter"] ?? "Anonymous").toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
