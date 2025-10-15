import 'package:flutter/material.dart';
import '../../model/elderly_person.dart';
import 'review_card.dart';
import 'no_reviews_state.dart';

class ReviewsList extends StatelessWidget {
  final ElderlyPerson person;

  const ReviewsList({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'รีวิวจากลูกค้า',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Display actual reviews or no reviews state
        if (person.hasReviews)
          ...person.reviews.map((review) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ReviewCard(
              reviewerName: review.reviewerName,
              rating: review.rating,
              review: review.comment,
              timeAgo: review.formattedDate,
            ),
          ))
        else
          const NoReviewsState(),
      ],
    );
  }
}