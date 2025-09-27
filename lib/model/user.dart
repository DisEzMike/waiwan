class User {
  final String id;
  final String displayName;
  final UserProfile profile;

  User({
    required this.id,
    required this.displayName,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'] ?? '',
      displayName: json['user']['displayname'] ?? '',
      profile: UserProfile.fromJson(json['profile'] ?? {}),
    );
  }
}

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String id_card;
  final String id_address;
  final String current_address;
  final String phone;
  final String gender;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.id_card,
    required this.id_address,
    required this.current_address,
    required this.phone,
    required this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      id_card: json['id_card'] ?? '',
      id_address: json['id_address'] ?? '',
      current_address: json['current_address'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
}
