class ChatMessage {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final String senderName;

  ChatMessage({
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.senderName,
  });

  // Factory constructor for creating ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] ?? '',
      isMe: json['is_me'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      senderName: json['sender_name'] ?? '',
    );
  }
}