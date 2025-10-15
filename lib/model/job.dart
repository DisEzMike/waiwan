enum JobApplicationStatus { pending, accepted, declined, canceled }

class MyJob {
  final int id;
  final String status;
  final String title;
  final String description;
  final double price;
  final String workType;
  final bool vehicle;
  final int maxSeniors;
  final DateTime startedAt;
  final DateTime endedAt;
  final Map<String, dynamic> location;
  final int ApplicationCount;
  final int AcceptedSeniorsCount;
  final String? chatRoomId;

  MyJob({
    required this.id,
    required this.status,
    required this.title,
    required this.description,
    required this.price,
    required this.workType,
    required this.vehicle,
    required this.maxSeniors,
    required this.startedAt,
    required this.endedAt,
    required this.location,
    required this.ApplicationCount,
    required this.AcceptedSeniorsCount,
    this.chatRoomId,
  });

  factory MyJob.fromJson(Map<String, dynamic> json) {
    return MyJob(
      id: json['id'],
      status: json['status'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      workType: json['work_type'],
      vehicle: json['vehicle'],
      maxSeniors: json['max_seniors'] ?? 0,
      startedAt: DateTime.parse(json['started_at']),
      endedAt: DateTime.parse(json['ended_at']),
      location: json['location'] ?? {},
      ApplicationCount: json['application_count'] ?? 0,
      AcceptedSeniorsCount: json['accepted_seniors_count'] ?? 0,
      chatRoomId: json['chat_room_id'],
    );
  }

  toJson() {
    return {
      'id': id,
      'status': status,
      'title': title,
      'description': description,
      'price': price,
      'work_type': workType,
      'vehicle': vehicle,
      'max_seniors': maxSeniors,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
      'location': location,
      'application_count': ApplicationCount,
      'accepted_seniors_count': AcceptedSeniorsCount,
      'chat_room_id': chatRoomId,
    };
  }
}

class JobDetail {
  final int id;
  final String status;
  final String userId;
  final String title;
  final String description;
  final double price;
  final String workType;
  final bool vehicle;
  final int maxSeniors;
  final DateTime startedAt;
  final DateTime endedAt;
  final Map<String, dynamic> location;
  final List<dynamic> applications;
  final List<dynamic> acceptedSeniors;
  final Map<String, dynamic>? chatRoom;

  JobDetail({
    required this.id,
    required this.status,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.workType,
    required this.vehicle,
    required this.maxSeniors,
    required this.startedAt,
    required this.endedAt,
    required this.location,
    required this.applications,
    required this.acceptedSeniors,
    this.chatRoom,
  });

  factory JobDetail.fromJson(Map<String, dynamic> json) {
    return JobDetail(
      id: json['id'],
      status: json['status'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      workType: json['work_type'],
      vehicle: json['vehicle'],
      maxSeniors: json['max_seniors'] ?? 0,
      startedAt: DateTime.parse(json['started_at']),
      endedAt: DateTime.parse(json['ended_at']),
      location: json['location'] ?? {},
      applications: json['applications'] ?? [],
      acceptedSeniors: json['accepted_seniors'] ?? [],
      chatRoom: json['chat_room'],
    );
  }

  toJson() {
    return {
      'id': id,
      'status': status,
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'work_type': workType,
      'vehicle': vehicle,
      'max_seniors': maxSeniors,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
      'location': location,
      'applications': applications,
      'accepted_seniors': acceptedSeniors,
      'chat_room': chatRoom,
    };
  }
}
