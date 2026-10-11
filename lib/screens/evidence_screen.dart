import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/evidence_store.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> _recordings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await EvidenceStore.load();
    if (mounted) setState(() => _recordings = r);
  }

  // ---------------- VIDEO ----------------
  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );
      if (video != null) {
        final updated = await EvidenceStore.add("video", video.path);
        setState(() => _recordings = updated);
        _msg("Video evidence saved");
      }
    } catch (e) {
      _msg("Video record nahi hua (camera check karein)");
    }
  }

  // ---------------- PHOTO ----------------
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final updated = await EvidenceStore.add("photo", photo.path);
        setState(() => _recordings = updated);
        _msg("Photo evidence saved");
      }
    } catch (e) {
      _msg("Photo capture nahi hua");
    }
  }

  // ---------------- OPEN ----------------
  Future<void> _open(String path) async {
    try {
      final uri = kIsWeb ? Uri.parse(path) : Uri.file(path);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _msg("Open nahi ho paya");
    }
  }

  Future<void> _delete(int index) async {
    final item = _recordings[index];
    if (!kIsWeb) {
      try {
        final f = File(item["path"] ?? "");
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    final updated = await EvidenceStore.removeAt(index);
    setState(() => _recordings = updated);
  }

  void _msg(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  String _formatTime(String iso) {
    final t = DateTime.tryParse(iso);
    if (t == null) return "";
    return DateFormat("d MMM, hh:mm a").format(t.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          "Evidence Recorder",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Video button
                    _bigButton(
                      icon: Icons.videocam,
                      label: "Record Video",
                      color: const Color(0xFF2209B4),
                      onTap: _recordVideo,
                    ),
                    // Photo button
                    _bigButton(
                      icon: Icons.camera_alt,
                      label: "Take Photo",
                      color: const Color(0xFF2488DA),
                      onTap: _takePhoto,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  "Capture video or photo evidence. Saved securely on your device.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: _recordings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 56,
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No evidence saved yet",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _recordings.length,
                    itemBuilder: (context, i) {
                      final r = _recordings[i];
                      final isVideo = r["type"] == "video";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade900 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(
                                0xFF2209B4,
                              ).withOpacity(0.12),
                              child: Icon(
                                isVideo ? Icons.videocam : Icons.image,
                                color: const Color(0xFF2209B4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isVideo
                                        ? "Video evidence"
                                        : "Photo evidence",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(r["time"] ?? ""),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.open_in_new,
                                color: Colors.green,
                              ),
                              onPressed: () => _open(r["path"] ?? ""),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              onPressed: () => _delete(i),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bigButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
