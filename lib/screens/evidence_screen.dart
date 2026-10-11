import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../services/evidence_store.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final ImagePicker _picker = ImagePicker();

  bool _isRecording = false;
  int _seconds = 0;
  List<Map<String, String>> _recordings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await EvidenceStore.load();
    if (mounted) setState(() => _recordings = r);
  }

  // ---------------- AUDIO ----------------
  Future<void> _toggleAudio() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _seconds = 0;
      });
      if (path != null) {
        final updated = await EvidenceStore.add("audio", path);
        setState(() => _recordings = updated);
        _msg("Audio saved");
      }
    } else {
      if (await _recorder.hasPermission()) {
        String path;
        if (kIsWeb) {
          path = "recording_${DateTime.now().millisecondsSinceEpoch}";
        } else {
          final dir = await getApplicationDocumentsDirectory();
          path =
              "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
        }
        await _recorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _seconds = 0;
        });
        _tick();
      } else {
        _msg("Microphone permission chahiye");
      }
    }
  }

  void _tick() async {
    while (_isRecording && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isRecording) break;
      setState(() => _seconds++);
    }
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
        _msg("Video saved");
      }
    } catch (e) {
      _msg("Video record nahi hua (camera check karein)");
    }
  }

  // ---------------- PLAY AUDIO ----------------
  Future<void> _playAudio(String path) async {
    try {
      if (kIsWeb) {
        await _player.play(UrlSource(path));
      } else {
        await _player.play(DeviceFileSource(path));
      }
    } catch (e) {
      _msg("Play nahi ho paya");
    }
  }

  Future<void> _delete(int index) async {
    final item = _recordings[index];
    // file delete (non-web)
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

  String get _timeStr {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
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
          // Record controls
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (_isRecording)
                  Text(
                    "● REC  $_timeStr",
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Audio button
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _toggleAudio,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording
                                  ? Colors.red
                                  : const Color(0xFF2209B4),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_isRecording
                                              ? Colors.red
                                              : const Color(0xFF2209B4))
                                          .withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRecording ? "Stop" : "Audio",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    // Video button
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _isRecording ? null : _recordVideo,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording
                                  ? Colors.grey
                                  : const Color(0xFF2488DA),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2488DA,
                                  ).withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Video",
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Record audio or video evidence. Saved on your device.",
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

          // Recordings list
          Expanded(
            child: _recordings.isEmpty
                ? Center(
                    child: Text(
                      "No recordings yet",
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _recordings.length,
                    itemBuilder: (context, i) {
                      final r = _recordings[i];
                      final isAudio = r["type"] == "audio";
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
                              backgroundColor:
                                  (isAudio
                                          ? const Color(0xFF2209B4)
                                          : const Color(0xFF2488DA))
                                      .withOpacity(0.12),
                              child: Icon(
                                isAudio ? Icons.mic : Icons.videocam,
                                color: isAudio
                                    ? const Color(0xFF2209B4)
                                    : const Color(0xFF2488DA),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAudio
                                        ? "Audio recording"
                                        : "Video recording",
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
                            if (isAudio)
                              IconButton(
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.green,
                                ),
                                onPressed: () => _playAudio(r["path"] ?? ""),
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
}
