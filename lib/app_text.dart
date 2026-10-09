import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';

/// Central jagah jahan saare texts English + Urdu mein hain.
/// Use: final t = AppText.of(context); ... Text(t.homeTitle)
class AppText {
  final bool ur; // true = Urdu

  AppText(this.ur);

  static AppText of(BuildContext context) {
    final isUrdu = context.watch<LocaleProvider>().isUrdu;
    return AppText(isUrdu);
  }

  String _t(String en, String urdu) => ur ? urdu : en;

  // ---------- App ----------
  String get appName => _t("Crime Rate Alert", "کرائم ریٹ الرٹ");
  String get tagline =>
      _t("Stay Informed, Stay Safe", "باخبر رہیں، محفوظ رہیں");

  // ---------- Common ----------
  String get search => _t("Search", "تلاش کریں");
  String get cancel => _t("Cancel", "منسوخ کریں");
  String get clear => _t("Clear", "صاف کریں");
  String get retry => _t("Retry", "دوبارہ کوشش");
  String get yes => _t("Yes", "ہاں");
  String get no => _t("No", "نہیں");
  String get loading => _t("Loading...", "لوڈ ہو رہا ہے...");
  String get errorGeneric => _t("Something went wrong", "کچھ غلط ہو گیا");

  // ---------- Home ----------
  String get enterCity => _t("Enter City Name", "شہر کا نام لکھیں");
  String get crimeLevel => _t("Crime Level", "جرائم کی سطح");
  String get recentSearches => _t("Recent Searches", "حالیہ تلاشیں");
  String get errorFetch =>
      _t("Error fetching crime rate", "کرائم ریٹ حاصل کرنے میں خرابی");

  // ---------- Quick boxes ----------
  String get crimeCategories => _t("Crime Categories", "جرائم کی اقسام");
  String get alerts => _t("Alerts", "انتباہات");
  String get safetyTips => _t("Safety Tips", "حفاظتی تجاویز");
  String get settings => _t("Settings", "ترتیبات");
  String get analytics => _t("Analytics", "تجزیات");
  String get map => _t("Map", "نقشہ");
  String get aiAssistant => _t("AI Assistant", "اے آئی اسسٹنٹ");

  // ---------- Crime levels ----------
  String get high => _t("High", "زیادہ");
  String get medium => _t("Medium", "درمیانہ");
  String get low => _t("Low", "کم");

  // ---------- Alerts screen ----------
  String get crimeAlerts => _t("Crime Alerts", "جرائم کے انتباہات");
  String get lastSearchResult => _t("Last Search Result", "آخری تلاش کا نتیجہ");
  String get safetyRecommendations =>
      _t("Safety Recommendations", "حفاظتی سفارشات");
  String get quickActions => _t("Quick Actions", "فوری اقدامات");
  String get emergency => _t("Emergency", "ایمرجنسی");
  String get emergencyContacts => _t("Emergency Contacts", "ایمرجنسی رابطے");
  String get tapToCall =>
      _t("Tap a number to call", "کال کرنے کے لیے نمبر پر ٹیپ کریں");
  String get police => _t("Police", "پولیس");
  String get ambulance => _t("Ambulance", "ایمبولینس");
  String get fireBrigade => _t("Fire Brigade", "فائر بریگیڈ");
  String get home => _t("Home", "ہوم");

  // ---------- Settings ----------
  String get language => _t("Language", "زبان");
  String get darkMode => _t("Dark Mode", "ڈارک موڈ");
  String get darkModeSub => _t("Switch to dark mode", "ڈارک موڈ آن کریں");
  String get notifications => _t("Notifications", "اطلاعات");
  String get notificationsSub =>
      _t("Enable push notifications", "پش اطلاعات آن کریں");
  String get languageSub => _t("Selected", "منتخب شدہ");
  String get aboutApp => _t("About App", "ایپ کے بارے میں");
  String get aboutAppSub => _t("App information", "ایپ کی معلومات");
  String get logoutSub =>
      _t("Sign out from your account", "اپنے اکاؤنٹ سے سائن آؤٹ کریں");
  String get version => _t("Version", "ورژن");
  String get logout => _t("Logout", "لاگ آؤٹ");
  String get logoutConfirm => _t(
    "Are you sure you want to log out?",
    "کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟",
  );
  String get yesLogout => _t("Yes, Log Out", "ہاں، لاگ آؤٹ کریں");
  String get loggedOut =>
      _t("Logged out successfully!", "کامیابی سے لاگ آؤٹ ہو گئے!");

  // ---------- Language screen ----------
  String get selectedLanguage => _t("Selected Language", "منتخب زبان");
  String get languageChanged => _t("Language changed", "زبان تبدیل ہو گئی");

  // ---------- Analytics ----------
  String get totalSearches => _t("Total Searches", "کل تلاشیں");
  String get weeklyTrends => _t("Weekly Crime Trends", "ہفتہ وار رجحانات");
  String get monthlyTrends => _t("Monthly Crime Trends", "ماہانہ رجحانات");
  String get topCities => _t("Top Searched Cities", "زیادہ تلاش شدہ شہر");
  String get crimeLevelSplit =>
      _t("Crime Level Split", "جرائم کی سطح کی تقسیم");

  // ---------- Assistant ----------
  String get crimeAssistant => _t("Crime Assistant", "کرائم اسسٹنٹ");
  String get askQuestion => _t("Type your question...", "اپنا سوال لکھیں...");
  String get clearChat => _t("Clear chat", "چیٹ صاف کریں");
  String get greeting => _t(
    "Hello! I'm your Crime Safety Assistant. Ask me about any city's crime info, safety tips, or any crime-related question.",
    "السلام علیکم! میں آپ کا کرائم سیفٹی اسسٹنٹ ہوں۔ کسی بھی شہر کی جرائم کی معلومات، حفاظتی تجاویز یا کوئی بھی سوال پوچھیں۔",
  );

  // ---------- Map ----------
  String get crimeMap => _t("Crime Map", "جرائم کا نقشہ");

  // ---------- Crime Detail ----------
  String get cityLabel => _t("City", "شہر");
  String get crimeType => _t("Crime Type", "جرم کی قسم");
  String get reportedIncidents => _t("Reported Incidents", "رپورٹ شدہ واقعات");
  String get severityIndex => _t("Crime Severity Index", "جرائم کی شدت انڈیکس");
  String get safetyTipsColon => _t("Safety Tips:", "حفاظتی تجاویز:");
  String get inWord => _t("in", "میں");

  List<String> detailTipsFor(String crimeType) {
    switch (crimeType.toLowerCase()) {
      case 'theft':
        return ur
            ? [
                "اپنے دروازے اور کھڑکیاں ہمیشہ لاک رکھیں۔",
                "عوامی جگہوں پر قیمتی اشیاء نہ دکھائیں۔",
                "ممکن ہو تو سیکیورٹی سسٹم لگائیں۔",
              ]
            : [
                "Always lock your doors and windows.",
                "Avoid displaying valuables in public.",
                "Install a security system if possible.",
              ];
      case 'robbery':
        return ur
            ? [
                "کم بھیڑ والے علاقوں میں چوکنا رہیں۔",
                "رات دیر گئے اکیلے چلنے سے گریز کریں۔",
                "مشکوک سرگرمی فوراً رپورٹ کریں۔",
              ]
            : [
                "Stay alert in less crowded areas.",
                "Avoid walking alone late at night.",
                "Report suspicious activity immediately.",
              ];
      case 'cybercrime':
        return ur
            ? [
                "مضبوط اور منفرد پاس ورڈ استعمال کریں۔",
                "آن لائن ذاتی معلومات شیئر کرنے سے گریز کریں۔",
                "اپنا سافٹ ویئر اپ ٹو ڈیٹ رکھیں۔",
              ]
            : [
                "Use strong and unique passwords.",
                "Avoid sharing personal info online.",
                "Keep your software up to date.",
              ];
      default:
        return ur
            ? ["اپنے علاقے میں محفوظ اور چوکنا رہیں۔"]
            : ["Stay safe and alert in your area."];
    }
  }

  // ---------- About App ----------
  String get aboutDescription => _t(
    "Crime Rate Alert helps you stay informed about safety concerns in your area. Get real-time alerts, explore crime statistics, and make smart safety decisions.",
    "کرائم ریٹ الرٹ آپ کو اپنے علاقے کے حفاظتی مسائل سے باخبر رکھتا ہے۔ ریئل ٹائم انتباہات حاصل کریں، جرائم کے اعداد و شمار دیکھیں اور بہتر حفاظتی فیصلے کریں۔",
  );
  String get staySafeStayAlert =>
      _t("Stay Safe, Stay Alert", "محفوظ رہیں، چوکنا رہیں");

  // ---------- Safety Tips list ----------
  List<String> get safetyTipsList => ur
      ? [
          "رات دیر گئے سفر سے گریز کریں، خاص طور پر انجان یا کم روشنی والے علاقوں میں۔ اگر سفر ضروری ہو تو روشن عوامی جگہوں پر رہیں اور کسی کو اپنی جگہ کے بارے میں بتائیں۔",
          "اپنے فون میں ایمرجنسی نمبر محفوظ کریں — پولیس، ایمبولینس، فائر بریگیڈ اور قابلِ اعتماد رابطے۔",
          "بھیڑ والی جگہوں جیسے بازار، پبلک ٹرانسپورٹ اور تقریبات میں چوکنا رہیں۔ اپنا سامان محفوظ رکھیں۔",
          "اجنبیوں کے ساتھ ذاتی معلومات شیئر نہ کریں — پورا نام، پتہ، نمبر یا مالی تفصیلات۔",
          "اپنی حِس پر بھروسہ کریں۔ اگر کچھ غلط محسوس ہو تو فوراً وہاں سے ہٹ جائیں اور مدد طلب کریں۔",
          "اپنا موبائل چارج رکھیں اور پورٹیبل چارجر ساتھ رکھیں۔ لوکیشن آن رکھیں اور قابلِ اعتماد رابطوں سے شیئر کریں۔",
          "اپنے گھر اور گاڑی کو اچھی طرح لاک کریں۔ ممکن ہو تو سیکیورٹی کیمرے یا اسمارٹ لاک لگائیں۔",
          "عوامی جگہوں پر مہنگی جیولری یا گیجٹس دکھانے سے گریز کریں تاکہ چوری کا خطرہ کم ہو۔",
          "رات کو یا ویران جگہوں پر اے ٹی ایم استعمال کرتے وقت محتاط رہیں۔ روشن مشینیں استعمال کریں۔",
          "مقامی کرائم الرٹس اور سیفٹی اپڈیٹس سے باخبر رہیں — آفیشل ایپس یا کمیونٹی گروپس کے ذریعے۔",
          "گھر میں داخل کرنے سے پہلے ڈیلیوری یا مرمت کرنے والوں کی شناخت کی تصدیق کریں۔",
          "ڈرائیو کرتے وقت دروازے لاک رکھیں اور کھڑکیاں تھوڑی بند رکھیں۔ ٹریفک قوانین پر عمل کریں۔",
          "بچوں کو بنیادی حفاظتی اصول سکھائیں — اجنبیوں سے بات نہ کرنا اور ایمرجنسی نمبر ملانا۔",
          "اگر آپ کو تعاقب یا خطرہ محسوس ہو تو قریبی عوامی جگہ یا دکان پر جا کر فوراً مدد مانگیں۔",
        ]
      : [
          "Avoid travelling late at night, especially in unfamiliar or poorly lit areas. If you must travel, stay in well-lit public spaces and inform someone of your whereabouts.",
          "Save emergency numbers in your phone including local police, ambulance, fire department and trusted contacts who can help in case of emergency.",
          "Stay alert in crowded areas such as markets, public transport, and events. Keep your belongings secure and be aware of your surroundings at all times.",
          "Don't share personal information with strangers including your full name, address, number, or financial details. Be cautious of social engineering attempts.",
          "Trust your instincts. If something feels wrong or unsafe, remove yourself from the situation immediately and seek help from authorities or trusted individuals.",
          "Keep your mobile phone charged and carry a portable charger. Ensure location services are enabled for emergency situations and share your location with trusted contacts.",
          "Lock your home and vehicles properly. Install security cameras or smart locks if possible for better protection.",
          "Avoid displaying expensive jewelry or gadgets in public places to reduce the risk of theft.",
          "Be careful when using ATMs at night or in isolated areas. Use well-lit machines and stay alert to your surroundings.",
          "Stay informed about local crime alerts or safety updates through official apps or community groups.",
          "Always verify the identity of delivery or repair persons before letting them into your home.",
          "While driving, keep doors locked and windows slightly closed. Avoid distractions and follow traffic rules strictly.",
          "Teach children basic safety rules — like not talking to strangers and knowing how to call emergency numbers.",
          "If you feel followed or unsafe, go to a nearby public place or shop and ask for help immediately.",
        ];

  // ---------- Crime Categories ----------
  String get enterCityDialog => _t("Enter City Name", "شہر کا نام لکھیں");
  String get cityHint => _t("e.g. Karachi, Lahore", "مثلاً کراچی، لاہور");
  String get go => _t("Go", "جائیں");

  String crimeTitleFor(String key) {
    switch (key) {
      case 'theft':
        return _t("Theft", "چوری");
      case 'robbery':
        return _t("Robbery", "ڈکیتی");
      case 'cybercrime':
        return _t("Cybercrime", "سائبر کرائم");
      case 'harassment':
        return _t("Harassment", "ہراسانی");
      case 'assault':
        return _t("Assault", "حملہ");
      case 'vandalism':
        return _t("Vandalism", "توڑ پھوڑ");
      case 'fraud':
        return _t("Fraud", "دھوکہ دہی");
      case 'drugs':
        return _t("Drug Offense", "منشیات کا جرم");
      default:
        return key;
    }
  }

  String crimeDescFor(String key) {
    switch (key) {
      case 'theft':
        return _t(
          "Unauthorized taking of someone else's property with intent to permanently deprive them of it.",
          "کسی دوسرے کی ملکیت کو اجازت کے بغیر مستقل طور پر لے لینا۔",
        );
      case 'robbery':
        return _t(
          "Taking property from a person using force, threat of force, or intimidation.",
          "طاقت، دھمکی یا خوف کے ذریعے کسی سے مال چھیننا۔",
        );
      case 'cybercrime':
        return _t(
          "Criminal activities carried out using computers, networks or digital devices.",
          "کمپیوٹر، نیٹ ورک یا ڈیجیٹل آلات کے ذریعے کیے جانے والے جرائم۔",
        );
      case 'harassment':
        return _t(
          "Unwanted behavior that is intended to disturb or upset other person repeatedly.",
          "بار بار کسی کو پریشان یا تنگ کرنے والا ناپسندیدہ رویہ۔",
        );
      case 'assault':
        return _t(
          "Intentional act that creates fear of imminent harmful or offensive contact.",
          "جان بوجھ کر ایسا عمل جو نقصان یا حملے کا خوف پیدا کرے۔",
        );
      case 'vandalism':
        return _t(
          "Deliberate destruction or damage to public or private property.",
          "سرکاری یا نجی ملکیت کو جان بوجھ کر نقصان پہنچانا۔",
        );
      case 'fraud':
        return _t(
          "Wrongful deception intended to result in financial or personal gain.",
          "مالی یا ذاتی فائدے کے لیے کیا گیا غلط دھوکہ۔",
        );
      case 'drugs':
        return _t(
          "Crimes related to illegal possession, distribution, or manufacturing of controlled substances.",
          "منشیات کے غیر قانونی قبضے، تقسیم یا تیاری سے متعلق جرائم۔",
        );
      default:
        return "";
    }
  }
}
