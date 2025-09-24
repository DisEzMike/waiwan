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
}