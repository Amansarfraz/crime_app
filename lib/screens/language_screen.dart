import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../locale_provider.dart';
import '../app_text.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = context.watch<LocaleProvider>();
    final t = AppText.of(context);
    final currentCode = localeProvider.locale.languageCode;

    final languages = [
      {"code": "en", "name": "English", "native": "English", "flag": "🇬🇧"},
      {"code": "ur", "name": "Urdu", "native": "اردو", "flag": "🇵🇰"},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        title: Text(
          t.language,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.selectedLanguage,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) {
              final selected = lang["code"] == currentCode;
              return GestureDetector(
                onTap: () async {
                  await localeProvider.setLanguage(lang["code"]!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.languageChanged),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF2209B4).withOpacity(0.1)
                        : (isDark ? Colors.grey.shade900 : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2209B4)
                          : (isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(lang["flag"]!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang["name"]!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            lang["native"]!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (selected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF2209B4),
                          size: 26,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
