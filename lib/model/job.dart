class Job {
  final String id;
  final int status;
  final String userId;
  final String seniorId;
  final String title;
  final String description;
  final String price;
  final String workType;
  final bool vehicle;

  Job({
    required this.id,
    required this.status,
    required this.userId,
    required this.seniorId,
    required this.title,
    required this.description,
    required this.price,
    required this.workType,
    required this.vehicle,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      status: json['status'],
      userId: json['user_id'],
      seniorId: json['senior_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      workType: json['work_type'],
      vehicle: json['vehicle'],
    );
  }
}
