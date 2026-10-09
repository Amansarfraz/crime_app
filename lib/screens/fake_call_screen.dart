import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FakeCallScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;

  const FakeCallScreen({
    super.key,
    required this.callerName,
    this.callerNumber = "+92 300 0000000",
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _accepted = false;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    // vibrate feel (haptic) jab call aaye
    HapticFeedback.heavyImpact();
  }

  void _accept() {
    setState(() => _accepted = true);
    // call timer start
    _tick();
  }

  void _tick() async {
    while (_accepted && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_accepted) break;
      setState(() => _seconds++);
    }
  }

  String get _timeStr {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2733),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Status text
            Text(
              _accepted ? _timeStr : "Incoming call...",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 30),

            // Avatar
            CircleAvatar(
              radius: 65,
              backgroundColor: Colors.grey.shade700,
              child: Text(
                widget.callerName.isNotEmpty
                    ? widget.callerName[0].toUpperCase()
                    : "?",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Name
            Text(
              widget.callerName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.callerNumber,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
            ),

            const Spacer(),

            // Buttons
            if (!_accepted)
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline
                    _callButton(
                      color: Colors.red,
                      icon: Icons.call_end,
                      label: "Decline",
                      onTap: () => Navigator.pop(context),
                    ),
                    // Accept
                    _callButton(
                      color: Colors.green,
                      icon: Icons.call,
                      label: "Accept",
                      onTap: _accept,
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: _callButton(
                  color: Colors.red,
                  icon: Icons.call_end,
                  label: "End",
                  onTap: () => Navigator.pop(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _callButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
