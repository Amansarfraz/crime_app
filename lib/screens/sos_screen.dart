import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../services/sos_store.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  List<Map<String, String>> _contacts = [];
  bool _loading = true;
  bool _fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final c = await SosStore.load();
    if (!mounted) return;
    setState(() {
      _contacts = c;
      _loading = false;
    });
  }

  // ---------------- GET LOCATION ----------------
  Future<String> _getLocationLink() async {
    try {
      // permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return "";
      }

      final pos = await Geolocator.getCurrentPosition();
      return "https://maps.google.com/?q=${pos.latitude},${pos.longitude}";
    } catch (e) {
      return "";
    }
  }

  // ---------------- SEND SOS ----------------
  Future<void> _sendSos(String number, {required bool whatsapp}) async {
    setState(() => _fetchingLocation = true);

    final locationLink = await _getLocationLink();

    setState(() => _fetchingLocation = false);

    final locText = locationLink.isEmpty
        ? "(location unavailable)"
        : locationLink;
    final message =
        "🚨 EMERGENCY! I'm in danger and need help immediately.\n"
        "My current location: $locText";

    final cleanNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');

    Uri uri;
    if (whatsapp) {
      uri = Uri.parse(
        "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}",
      );
    } else {
      uri = Uri.parse("sms:$cleanNumber?body=${Uri.encodeComponent(message)}");
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not open: $number")));
      }
    }
  }

  // ---------------- CHOOSE WHATSAPP / SMS ----------------
  void _chooseChannel(String name, String number) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Send SOS to $name",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text("WhatsApp"),
              onTap: () {
                Navigator.pop(ctx);
                _sendSos(number, whatsapp: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sms, color: Colors.blue),
              title: const Text("SMS"),
              onTap: () {
                Navigator.pop(ctx);
                _sendSos(number, whatsapp: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- ADD CONTACT ----------------
  void _addContact() {
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Emergency Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: numberCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Number (with country code, e.g. 923001234567)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final number = numberCtrl.text.trim();
              if (name.isEmpty || number.isEmpty) return;
              final updated = await SosStore.add(name, number);
              if (!mounted) return;
              setState(() => _contacts = updated);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _removeContact(int index) async {
    final updated = await SosStore.removeAt(index);
    setState(() => _contacts = updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        title: Text(
          "SOS Emergency",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- BIG SOS BUTTON ----
            Center(
              child: GestureDetector(
                onTap: _fetchingLocation
                    ? null
                    : () {
                        if (_contacts.isEmpty) {
                          _sendSos("15", whatsapp: false);
                        } else {
                          // pehla contact quick trigger
                          _chooseChannel(
                            _contacts.first["name"] ?? "",
                            _contacts.first["number"] ?? "",
                          );
                        }
                      },
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red.shade600, Colors.red.shade900],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _fetchingLocation
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "SOS",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tap SOS to send your live location and an emergency message.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            // ---- POLICE 15 ----
            _contactCard(
              name: "Police (Emergency)",
              number: "15",
              isDark: isDark,
              builtin: true,
              onTap: () => _sendSos("15", whatsapp: false),
              onCall: () => _dial("15"),
            ),

            const SizedBox(height: 20),

            // ---- USER CONTACTS ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Emergency Contacts",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.red),
                  onPressed: _addContact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_contacts.isEmpty)
              Text(
                "No contacts yet. Tap + to add a trusted person.",
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              )
            else
              ..._contacts.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                return _contactCard(
                  name: c["name"] ?? "",
                  number: c["number"] ?? "",
                  isDark: isDark,
                  onTap: () =>
                      _chooseChannel(c["name"] ?? "", c["number"] ?? ""),
                  onCall: () => _dial(c["number"] ?? ""),
                  onDelete: () => _removeContact(i),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _dial(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _contactCard({
    required String name,
    required String number,
    required bool isDark,
    required VoidCallback onTap,
    required VoidCallback onCall,
    VoidCallback? onDelete,
    bool builtin = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: builtin ? Colors.red.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.shade100,
            child: Icon(
              builtin ? Icons.local_police : Icons.person,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.red),
            tooltip: "Send SOS",
            onPressed: onTap,
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            tooltip: "Call",
            onPressed: onCall,
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
