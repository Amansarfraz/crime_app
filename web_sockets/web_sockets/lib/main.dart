import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(MyChatApp());
}

class MyChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(currentUser: "Aman", otherUser: "Sara"),
    );
  }
}
