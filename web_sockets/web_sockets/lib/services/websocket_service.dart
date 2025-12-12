import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel channel;

  void connect(String userId) {
    channel = WebSocketChannel.connect(
      Uri.parse("ws://127.0.0.1:8000/ws/$userId"),
    );
  }

  Stream getStream() => channel.stream;

  void sendMessage(String toUser, String text) {
    channel.sink.add(jsonEncode({"to": toUser, "text": text}));
  }

  void disconnect() {
    channel.sink.close();
  }
}
