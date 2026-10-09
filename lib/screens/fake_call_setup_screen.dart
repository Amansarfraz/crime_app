import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fake_call_screen.dart';

class FakeCallSetupScreen extends StatefulWidget {
  const FakeCallSetupScreen({super.key});

  @override
  State<FakeCallSetupScreen> createState() => _FakeCallSetupScreenState();
}

class _FakeCallSetupScreenState extends State<FakeCallSetupScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _numberCtrl = TextEditingController();

  int _delay = 0; // 0 = foran
  Timer? _timer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString("fake_call_name") ?? "Mom";
      _numberCtrl.text =
          prefs.getString("fake_call_number") ?? "+92 300 1234567";
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("fake_call_name", _nameCtrl.text.trim());
    await prefs.setString("fake_call_number", _numberCtrl.text.trim());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  void _trigger() async {
    await _save();
    final name = _nameCtrl.text.trim().isEmpty ? "Mom" : _nameCtrl.text.trim();
    final number = _numberCtrl.text.trim();

    if (_delay == 0) {
      _openCall(name, number);
      return;
    }

    // countdown
    setState(() => _countdown = _delay);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        _openCall(name, number);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fake call in $_delay seconds..."),
        duration: Duration(seconds: _delay),
      ),
    );
  }

  void _openCall(String name, String number) {
    if (!mounted) return;
    setState(() => _countdown = 0);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FakeCallScreen(callerName: name, callerNumber: number),
      ),
    );
  }

  void _cancelCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          "Fake Call",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2209B4).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2209B4)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Trigger a fake incoming call to escape an uncomfortable or unsafe situation.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Caller Name",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "e.g. Mom, Dad, Boss",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "Caller Number",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _numberCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "+92 300 1234567",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "When should it ring?",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _delayChip("Now", 0, isDark),
                _delayChip("5s", 5, isDark),
                _delayChip("10s", 10, isDark),
                _delayChip("30s", 30, isDark),
              ],
            ),

            const SizedBox(height: 30),

            // countdown or trigger
            if (_countdown > 0)
              Column(
                children: [
                  Text(
                    "Ringing in $_countdown s...",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2209B4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _cancelCountdown,
                    child: const Text("Cancel"),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _trigger,
                  icon: const Icon(Icons.phone_in_talk, color: Colors.white),
                  label: Text(
                    "Trigger Fake Call",
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
          ],
        ),
      ),
    );
  }

  Widget _delayChip(String label, int value, bool isDark) {
    final selected = _delay == value;
    return GestureDetector(
      onTap: () => setState(() => _delay = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2209B4)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
