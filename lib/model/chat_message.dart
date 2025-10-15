class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderType;
  final String? senderName;
  final String message;
  final bool isRead;
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
    required this.senderType,
    this.senderName,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.isMe = false,
    this.isPayment = false,
    this.paymentDetails,
    this.isMap = false,
  });

  // Factory constructor for creating ChatMessage from JSON (API format)
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderType: json['sender_type']?.toString() ?? '',
      senderName: json['sender_name']?.toString(),
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      isMe: json['isMe'] ?? false,
      isPayment: json['is_payment'] ?? false,
      paymentDetails:
          json['payment_details'] != null
              ? PaymentDetails.fromJson(json['payment_details'])
              : null,
      isMap: json['is_map'] ?? false,
    );
  }

  // Convert to JSON for sending
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'sender_type': senderType,
      'sender_name': senderName,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'isMe': isMe,
      if (isPayment) 'is_payment': isPayment,
      if (paymentDetails != null) 'payment_details': paymentDetails!.toJson(),
      if (isMap) 'is_map': isMap,
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
