class ChatRoom {
  final String id;
  final String jobId;
  final String? jobTitle;
  final String userId;
  final String userName;
  final String seniorId;
  final String seniorName;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final int unreadCount;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.jobId,
    this.jobTitle,
    required this.userId,
    required this.userName,
    required this.seniorId,
    required this.seniorName,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.unreadCount = 0,
    this.isActive = true,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id']?.toString() ?? '',
      jobId: json['job_id']?.toString() ?? '',
      jobTitle: json['job_title'],
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      seniorId: json['senior_id']?.toString() ?? '',
      seniorName: json['senior_name']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.tryParse(json['last_message_at'].toString()) 
          : null,
      lastMessageContent: json['last_message_content'],
      lastMessageSenderId: json['last_message_sender_id'],
      unreadCount: json['unread_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'job_title': jobTitle,
      'user_id': userId,
      'user_name': userName,
      'senior_id': seniorId,
      'senior_name': seniorName,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_content': lastMessageContent,
      'last_message_sender_id': lastMessageSenderId,
      'unread_count': unreadCount,
      'is_active': isActive,
    };
  }

  ChatRoom copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? userId,
    String? userName,
    String? seniorId,
    String? seniorName,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderId,
    int? unreadCount,
    bool? isActive,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      seniorId: seniorId ?? this.seniorId,
      seniorName: seniorName ?? this.seniorName,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoom &&
        other.id == id &&
        other.jobId == jobId &&
        other.userId == userId &&
        other.seniorId == seniorId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ jobId.hashCode ^ userId.hashCode ^ seniorId.hashCode;
  }

  @override
  String toString() {
    return 'ChatRoom(id: $id, jobId: $jobId, jobTitle: $jobTitle, userId: $userId, userName: $userName, seniorId: $seniorId, seniorName: $seniorName)';
  }
}