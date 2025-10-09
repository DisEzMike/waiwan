class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String sender_type;
  final String message;
  final bool is_read;
  final DateTime createdAt;
  bool isMe;
  
  // Additional properties for UI features
  final bool isPayment;
  final PaymentDetails? paymentDetails;
  final bool isMap;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.sender_type,
    required this.message,
    required this.is_read,
    required this.createdAt,
    this.isMe = false,
    this.isPayment = false,
    this.paymentDetails,
    this.isMap = false,
  });

  // Factory constructor for creating ChatMessage from JSON (WebSocket format)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      roomId: json['room_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      sender_type: json['sender_type'] ?? '',
      message: json['message'] ?? '',
      is_read: json['is_read'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      isMe: json['isMe'] ?? false,
      isPayment: json['is_payment'] ?? false,
      paymentDetails: json['payment_details'] != null
          ? PaymentDetails.fromJson(json['payment_details'])
          : null,
      isMap: json['is_map'] ?? false,
    );
  }

  // Convert to JSON for sending via WebSocket
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'sender_type': sender_type,
      'message': message,
      'is_read': is_read,
      'created_at': createdAt.toIso8601String(),
      'isMe': isMe,
    };
  }

  // Create a copy with different values
  // ChatMessage copyWith({
  //   String? id,
  //   String? roomId,
  //   String? senderId,
  //   String? message,
  //   bool? isMe,
  //   DateTime? timestamp,
  //   String? senderName,
  //   String? senderRole,
  //   String? messageType,
  //   bool? isPayment,
  //   PaymentDetails? paymentDetails,
  //   bool? isMap,
  //   bool? isRead,
  //   Map<String, dynamic>? metadata,
  // }) {
  //   return ChatMessage(
  //     id: id ?? this.id,
  //     roomId: roomId ?? this.roomId,
  //     senderId: senderId ?? this.senderId,
  //     sender_type: sender_type,
  //     message: message ?? this.message,
  //     is_read: isRead ?? this.is_read,
  //     createdAt: timestamp ?? this.createdAt,
  //   );
  // }
}

class PaymentDetails {
  final String jobTitle;
  final String payment;
  final String workType;
  final String paymentMethod;
  final String code;
  final String totalAmount;

  PaymentDetails({
    required this.jobTitle,
    required this.payment,
    required this.workType,
    required this.paymentMethod,
    required this.code,
    required this.totalAmount,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      jobTitle: json['job_title'] ?? '',
      payment: json['payment'] ?? '',
      workType: json['work_type'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      code: json['code'] ?? '',
      totalAmount: json['total_amount'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_title': jobTitle,
      'payment': payment,
      'work_type': workType,
      'payment_method': paymentMethod,
      'code': code,
      'total_amount': totalAmount,
    };
  }
}
