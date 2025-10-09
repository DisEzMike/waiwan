import 'package:waiwan/utils/config.dart';

import 'review_elderly.dart';

class ElderlyPerson {
  final String name;
  final String type;
  final String distance;
  final String ability;
  final String imageUrl;
  final int phoneNumber;
  final String chronicDiseases;
  final String workExperience;
  final String address;
  final List<Review> reviews;
  final bool isVerified;
  final bool vehicle;
  final bool offsiteWork;

  ElderlyPerson({
    required this.name,
    required this.type,
    required this.distance,
    required this.ability,
    required this.imageUrl,
    required this.phoneNumber,
    required this.chronicDiseases,
    required this.workExperience,
    required this.address,
    this.reviews = const [],
    this.isVerified = false,
    this.vehicle = false,
    this.offsiteWork = false,
  });

  // Factory constructor for creating ElderlyPerson from JSON
  factory ElderlyPerson.fromJson(Map<String, dynamic> json) {
    print(json['image_url']);
    if (json['image_url'] != null) {
      json['image_url'] = API_URL + json['image_url'];
    } else {
      json['image_url'] = 'https://placehold.co/600x400.png';
    }
    return ElderlyPerson(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      distance: '${json['distance']?.toString() ?? '0'} เมตร',
      ability: json['other_ability']?.toString() ?? '',
      imageUrl: json['image_url'],
      phoneNumber: _parseToInt(json['phone']),
      chronicDiseases: json['chronic_diseases']?.toString() ?? '',
      workExperience: json['work_experience']?.toString() ?? '',
      address: json['current_address']?.toString() ?? '',
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((reviewJson) => Review.fromJson(reviewJson))
              .toList() ??
          [],
      isVerified: json['is_verified'] == true,
      vehicle: json['vehicle'] == true,
      offsiteWork: json['offsite_work'] == true,
    );
  }

  // Helper method to safely parse various types to int
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
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
      name: name,
      type: type,
      distance: distance,
      ability: ability,
      imageUrl: imageUrl,
      phoneNumber: phoneNumber,
      chronicDiseases: chronicDiseases,
      workExperience: workExperience,
      address: address,
      reviews: updatedReviews,
      isVerified: isVerified,
      vehicle: vehicle,
      offsiteWork: offsiteWork,
    );
  }
}
