class ChatMessage {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final String senderName;
  final bool isPayment;
  final PaymentDetails? paymentDetails;
  final bool isMap;

  ChatMessage({
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.senderName,
    this.isPayment = false,
    this.paymentDetails,
    this.isMap = false,
  });

  // Factory constructor for creating ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] ?? '',
      isMe: json['is_me'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      senderName: json['sender_name'] ?? '',
      isPayment: json['is_payment'] ?? false,
      paymentDetails: json['payment_details'] != null 
          ? PaymentDetails.fromJson(json['payment_details'])
          : null,
      isMap: json['is_map'] ?? false,
    );
  }
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
}