class Message {
  final String sender;
  final String recipient;
  final String text;
  final DateTime ts; // backend field

  Message({
    required this.sender,
    required this.recipient,
    required this.text,
    required this.ts,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      recipient: json['recipient'],
      text: json['text'],
      ts: DateTime.parse(json['ts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender": sender,
      "recipient": recipient,
      "text": text,
      "ts": ts.toIso8601String(),
    };
  }
}
