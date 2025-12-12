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
      title: "FastAPI Chat",
      theme: ThemeData(primarySwatch: Colors.blue),

      home: ChatScreen(
        currentUser: "Aman", // ✔ your user ID / username
        otherUser: "Sara", // ✔ the person you are chatting with
      ),
    );
  }
}
