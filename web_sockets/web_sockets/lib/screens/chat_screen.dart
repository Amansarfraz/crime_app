import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/websocket_service.dart';
import '../widgets/message_tile.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String otherUser;

  ChatScreen({required this.currentUser, required this.otherUser, Key? key})
    : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgController = TextEditingController();
  final List<Message> messages = [];
  late WebSocketService ws;

  @override
  void initState() {
    super.initState();

    ws = WebSocketService();
    ws.connect(widget.currentUser);

    ws.getStream().listen((event) {
      final data = jsonDecode(event);
      final msg = Message.fromJson(data);

      setState(() {
        messages.add(msg);
      });
    });
  }

  void sendMessage() {
    if (msgController.text.trim().isEmpty) return;

    ws.sendMessage(widget.otherUser, msgController.text.trim());
    msgController.clear();
  }

  @override
  void dispose() {
    ws.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.otherUser}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageTile(
                  message: messages[index],
                  isMe: messages[index].sender == widget.currentUser,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: InputDecoration(
                      hintText: "Type message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
