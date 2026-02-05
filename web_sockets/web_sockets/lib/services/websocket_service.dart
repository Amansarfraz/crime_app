import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';

class WebSocketService {
  late WebSocketChannel channel;

  void connect(String userId) {
    final url = "ws://localhost:8000/ws/$userId";

    // ✅ HTML WebSocket for Flutter Web (Chrome / Edge)
    channel = HtmlWebSocketChannel.connect(url);
  }

  Stream getStream() => channel.stream;

  void sendMessage(String toUser, String text) {
    channel.sink.add(jsonEncode({"to": toUser, "text": text}));
  }

  void disconnect() {
    channel.sink.close();
  }
}
