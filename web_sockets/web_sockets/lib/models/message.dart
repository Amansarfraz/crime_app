class Message {
  final String sender;
  final String recipient;
  final String text;
  final DateTime ts;

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
}
