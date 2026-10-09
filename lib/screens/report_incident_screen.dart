import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../app_text.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  String _category = "Theft";
  bool _anonymous = true;
  bool _submitting = false;

  final List<String> _categories = [
    "Theft",
    "Robbery",
    "Harassment",
    "Assault",
    "Cybercrime",
    "Fraud",
    "Vandalism",
    "Suspicious Activity",
    "Other",
  ];

  @override
  void dispose() {
    _cityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final city = _cityCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (city.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("City aur description zaroori hai")),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.reportIncident(
        category: _category,
        city: city,
        description: desc,
        anonymous: _anonymous,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report submitted. Thank you!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Report submit nahi hui")));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
          t.ur ? "واقعہ رپورٹ کریں" : "Report Incident",
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2209B4).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: Color(0xFF2209B4)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.ur
                          ? "اپنے علاقے میں ہونے والا کوئی واقعہ رپورٹ کریں تاکہ دوسرے محفوظ رہیں۔"
                          : "Report an incident in your area to help keep others safe.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Category
            Text(
              t.crimeType,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 15,
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? "Theft"),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // City
            Text(
              t.cityLabel,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cityCtrl,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: t.ur ? "مثلاً کراچی" : "e.g. Karachi",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Description
            Text(
              t.ur ? "تفصیل" : "Description",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: t.ur
                    ? "کیا ہوا؟ مختصر تفصیل لکھیں..."
                    : "What happened? Briefly describe...",
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Anonymous toggle
            SwitchListTile(
              value: _anonymous,
              activeColor: const Color(0xFF2209B4),
              contentPadding: EdgeInsets.zero,
              title: Text(
                t.ur ? "گمنام رپورٹ" : "Report anonymously",
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                t.ur
                    ? "آپ کا نام ظاہر نہیں ہوگا"
                    : "Your identity will stay hidden",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              onChanged: (v) => setState(() => _anonymous = v),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2209B4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        t.ur ? "رپورٹ جمع کریں" : "Submit Report",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
