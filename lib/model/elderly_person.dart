import 'package:waiwan/utils/config.dart';

import 'review_elderly.dart';

class ElderlyPerson {
  final String id;
  final String displayName;
  final SeniorProfile profile;
  final SeniorAbility ability;
  final List<Review> reviews;
  final bool isVerified;
  final String? distance;

  ElderlyPerson({
    required this.id,
    required this.displayName,
    required this.profile,
    required this.ability,
    this.reviews = const [],
    this.isVerified = false,
    this.distance,
  });

  // Factory constructor for creating ElderlyPerson from JSON
  factory ElderlyPerson.fromJson(Map<String, dynamic> json) {
    if (json['image_url'] != null) {
      json['image_url'] = API_URL + json['image_url'];
    } else {
      json['image_url'] = 'https://placehold.co/600x400.png';
    }
    return ElderlyPerson(
      id: json['user']['id']?.toString() ?? '',
      displayName: json['user']['displayname']?.toString() ?? '',
      profile: SeniorProfile.fromJson(json['profile'] ?? {}),
      ability: SeniorAbility.fromJson(json['ability'] ?? {}),
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((reviewJson) => Review.fromJson(reviewJson))
              .toList() ??
          [],
      isVerified: json['is_verified'] == true,
      distance: json['distance'],
    );
  }

  // Calculate rating statistics from reviews
  RatingStats get ratingStats => RatingStats.fromReviews(reviews);

  // Get average rating (backward compatibility)
  double get rating => ratingStats.averageRating;

  // Get total review count
  int get reviewCount => reviews.length;

  // Get formatted rating string
  String get formattedRating => ratingStats.formattedRating;

  // Check if person has reviews
  bool get hasReviews => reviews.isNotEmpty;

  // Get recent reviews (last 5)
  List<Review> get recentReviews {
    final sortedReviews = List<Review>.from(reviews)
      ..sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
    return sortedReviews.take(5).toList();
  }

  // Add a new review
  ElderlyPerson addReview(Review review) {
    final updatedReviews = List<Review>.from(reviews)..add(review);
    return ElderlyPerson(
      id: id,
      displayName: displayName,
      profile: profile,
      ability: ability,
      reviews: updatedReviews,
      isVerified: isVerified,
    );
  }
}

class SeniorProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String idCard;
  final String iDaddress;
  final String currentAddress;
  final String chronicDiseases;
  final String contactPerson;
  final String contactPhone;
  final String phone;
  final String gender;
  final String imageUrl;

  SeniorProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.idCard,
    required this.iDaddress,
    required this.currentAddress,
    required this.chronicDiseases,
    required this.contactPerson,
    required this.contactPhone,
    required this.phone,
    required this.gender,
    required this.imageUrl,
  });

  factory SeniorProfile.fromJson(Map<String, dynamic> json) {
    if (json['image_url'] != null) {
      json['image_url'] = API_URL + json['image_url'];
    } else {
      json['image_url'] = 'https://placehold.co/600x400.png';
    }
    return SeniorProfile(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      idCard: json['id_card'] ?? '',
      iDaddress: json['id_address'] ?? '',
      currentAddress: json['current_address'] ?? '',
      chronicDiseases: json['chronic_diseases'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

class SeniorAbility {
  final String id;
  final String type;
  final String workExperience;
  final String otherAbility;
  final bool vehicle;
  final bool offsiteWork;

  SeniorAbility({
    required this.id,
    required this.type,
    required this.workExperience,
    required this.otherAbility,
    required this.vehicle,
    required this.offsiteWork,
  });

  factory SeniorAbility.fromJson(Map<String, dynamic> json) {
    return SeniorAbility(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      workExperience: json['work_experience'] ?? '',
      otherAbility: json['other_ability'] ?? '',
      vehicle: json['vehicle'] == true,
      offsiteWork: json['offsite_work'] == true,
    );
  }
}
