class Review {
  final String reviewerName;
  final String reviewerAvatar;
  final int rating;
  final String comment;
  final DateTime reviewDate;
  final String reviewId;

  Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.reviewDate,
    required this.reviewId,
    this.reviewerAvatar = '',
  });

  // Factory constructor for creating Review from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewerName: json['reviewer_name'] ?? '',
      reviewerAvatar: json['reviewer_avatar'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      reviewDate: DateTime.tryParse(json['review_date'] ?? '') ?? DateTime.now(),
      reviewId: json['review_id'] ?? '',
    );
  }

  // Helper method to get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(reviewDate);
    
    if (difference.inDays == 0) {
      return 'วันนี้';
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks สัปดาห์ที่แล้ว';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months เดือนที่แล้ว';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ปีที่แล้ว';
    }
  }

  // Helper method to validate rating (1-5 stars)
  bool get isValidRating => rating >= 1 && rating <= 5;
}

class RatingStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // star level -> count

  RatingStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  // Calculate rating stats from list of reviews
  factory RatingStats.fromReviews(List<Review> reviews) {
    if (reviews.isEmpty) {
      return RatingStats(
        averageRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
    }

    // Calculate average
    final totalRating = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    final average = totalRating / reviews.length;

    // Calculate distribution
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      if (review.isValidRating) {
        distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
      }
    }

    return RatingStats(
      averageRating: double.parse(average.toStringAsFixed(1)),
      totalReviews: reviews.length,
      ratingDistribution: distribution,
    );
  }

  // Get percentage for each star level
  double getPercentage(int starLevel) {
    if (totalReviews == 0) return 0.0;
    return (ratingDistribution[starLevel] ?? 0) / totalReviews * 100;
  }

  // Get formatted average rating string
  String get formattedRating => averageRating.toStringAsFixed(1);

  // Get star count for display
  int get fullStars => averageRating.floor();
  bool get hasHalfStar => (averageRating - fullStars) >= 0.5;
  int get emptyStars => 5 - fullStars - (hasHalfStar ? 1 : 0);
}