import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../app_text.dart';

class CrimeAssistantScreen extends StatefulWidget {
  const CrimeAssistantScreen({super.key});

  @override
  State<CrimeAssistantScreen> createState() => _CrimeAssistantScreenState();
}

class _CrimeAssistantScreenState extends State<CrimeAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService();

  final List<Map<String, String>> _messages = [];
  bool _sending = false;
  bool _loadingHistory = true;

  // voice
  late stt.SpeechToText _speech;
  bool _isListening = false;

  static const Map<String, String> _greeting = {
    "role": "assistant",
    "content":
        "Hello! 👋 I'm your Crime Safety Assistant. You can ask me about "
        "any city's crime information, safety tips, or any crime-related "
        "question.",
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadHistory();
  }

  // ----------------- VOICE INPUT -----------------
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == "done" || val == "notListening") {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (val) {
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
            // final result pe auto-send
            if (val.finalResult && _controller.text.trim().isNotEmpty) {
              setState(() => _isListening = false);
              _send();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // ----------------- LOAD HISTORY -----------------
  Future<void> _loadHistory() async {
    try {
      final history = await _api.getChatHistory();
      setState(() {
        _messages.clear();
        if (history.isEmpty) {
          _messages.add(Map<String, String>.from(_greeting));
        } else {
          _messages.addAll(history);
        }
        _loadingHistory = false;
      });
      _scrollToBottom();
    } catch (e) {
      // history load fail -> sirf greeting dikhao
      setState(() {
        _messages.clear();
        _messages.add(Map<String, String>.from(_greeting));
        _loadingHistory = false;
      });
    }
  }

  // ----------------- CLEAR HISTORY -----------------
  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear chat?"),
        content: const Text("Saari chat history delete ho jayegi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.clearChatHistory();
    } catch (_) {}

    setState(() {
      _messages.clear();
      _messages.add(Map<String, String>.from(_greeting));
    });
  }

  // ----------------- SEND -----------------
  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _sending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      // history (greeting nikaal ke, current user msg ke ilawa)
      final history = _messages
          .sublist(0, _messages.length - 1)
          .where((m) => m["content"] != _greeting["content"])
          .map((m) => {"role": m["role"]!, "content": m["content"]!})
          .toList();

      final reply = await _api.askAssistant(text, history);

      setState(() {
        _messages.add({"role": "assistant", "content": reply});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content":
              "Sorry, I couldn't respond right now. Please check your internet/server.",
        });
      });
    } finally {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppText.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2209B4),
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF2209B4),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              t.crimeAssistant,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: t.clearChat,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loadingHistory) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_sending && index == _messages.length) {
                  return _bubble(
                    t.ur ? "لکھ رہا ہے..." : "Typing...",
                    isUser: false,
                    isDark: isDark,
                    italic: true,
                  );
                }
                final msg = _messages[index];
                return _bubble(
                  msg["content"] ?? "",
                  isUser: msg["role"] == "user",
                  isDark: isDark,
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: t.askQuestion,
                      hintStyle: GoogleFonts.poppins(
                        color: isDark ? Colors.white54 : Colors.grey,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.grey.shade800
                          : const Color(0xFFEFEFEF),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Mic (voice) button
                GestureDetector(
                  onTap: _listen,
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.red
                          : (isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade400),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2209B4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(
    String text, {
    required bool isUser,
    required bool isDark,
    bool italic = false,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF2209B4)
              : (isDark ? Colors.grey.shade800 : const Color(0xFFEDEAFB)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isUser
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            fontSize: 14,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}
