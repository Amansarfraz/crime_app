import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageTile({required this.message, required this.isMe, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.sender,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            SizedBox(height: 5),
            Text(message.text, style: TextStyle(fontSize: 15)),
            SizedBox(height: 4),
            Text(
              message.ts.toLocal().toString(),
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
