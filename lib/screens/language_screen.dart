import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = 'English';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> languages = [
    'English',
    'Urdu',
    'Spanish',
    'French',
    'German',
    'Arabic',
    'Chinese',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeLanguage(String lang) {
    setState(() => selectedLanguage = lang);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Language changed to $lang"),
        backgroundColor: const Color(0xFF2209B4),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // 🔷 Header
          Container(
            height: 80,
            color: const Color(0xFF2209B4),
            padding: const EdgeInsets.only(top: 35, left: 16, right: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Language",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🌍 Language Options (Animated List)
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = lang == selectedLanguage;

                  return GestureDetector(
                    onTap: () => _changeLanguage(lang),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2209B4).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2209B4)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 16,
                              color: isSelected
                                  ? const Color(0xFF2209B4)
                                  : Colors.black,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF2209B4),
                              size: 22,
                            ),
                        ],
                      ),
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
