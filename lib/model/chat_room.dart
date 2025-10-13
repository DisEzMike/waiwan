import 'package:waiwan/model/chat_message.dart';

class ChatRoom {
  final String id;
  final int jobId;
  final String? jobTitle;
  final String userId;
  final String? userName;
  final List<SeniorInfo> seniors;
  final bool isActive;
  final DateTime createdAt;
  final int unreadCount;
  final ChatMessage? lastMessage;

  ChatRoom({
    required this.id,
    required this.jobId,
    this.jobTitle,
    required this.userId,
    this.userName,
    required this.seniors,
    required this.createdAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.isActive = true,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id']?.toString() ?? '',
      jobId: json['job_id'] ?? 0,
      jobTitle: json['job_title']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      seniors: (json['seniors'] as List<dynamic>?)
          ?.map((seniorJson) => SeniorInfo.fromJson(seniorJson as Map<String, dynamic>))
          .toList() ?? [],
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
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
      'seniors': seniors.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'is_active': isActive,
    };
  }

  // Helper getters
  String? get lastMessageContent => lastMessage?.message;
  DateTime? get lastMessageAt => lastMessage?.createdAt;
  String? get lastMessageSenderId => lastMessage?.senderId;

  ChatRoom copyWith({
    String? id,
    int? jobId,
    String? jobTitle,
    String? userId,
    String? userName,
    List<SeniorInfo>? seniors,
    bool? isActive,
    DateTime? createdAt,
    int? unreadCount,
    ChatMessage? lastMessage,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      seniors: seniors ?? this.seniors,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

// Senior info structure as returned by the API
class SeniorInfo {
  final String id;
  final String displayname;
  final String? profileId;

  SeniorInfo({
    required this.id,
    required this.displayname,
    this.profileId,
  });

  factory SeniorInfo.fromJson(Map<String, dynamic> json) {
    return SeniorInfo(
      id: json['id']?.toString() ?? '',
      displayname: json['displayname']?.toString() ?? '',
      profileId: json['profile_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayname': displayname,
      'profile_id': profileId,
    };
  }
}
