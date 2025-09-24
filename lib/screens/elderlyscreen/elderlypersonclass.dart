import 'reviewclass.dart';

class ElderlyPerson {
  final String name;
  final String distance;
  final String ability;
  final String imageUrl;
  final int phoneNumber;
  final String chronicDiseases;
  final String workExperience;
  final List<Review> reviews;
  final bool isVerified;

  ElderlyPerson({
    required this.name,
    required this.distance,
    required this.ability,
    required this.imageUrl,
    required this.phoneNumber,
    required this.chronicDiseases,
    required this.workExperience,
    this.reviews = const [],
    this.isVerified = false,
  });

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
      distance: distance,
      ability: ability,
      imageUrl: imageUrl,
      phoneNumber: phoneNumber,
      chronicDiseases: chronicDiseases,
      workExperience: workExperience,
      reviews: updatedReviews,
      isVerified: isVerified,
    );
  }
}