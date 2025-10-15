import 'package:flutter/material.dart';
import '../../model/elderly_person.dart';
import '../../widgets/review/rating_summary_card.dart';
import '../../widgets/review/reviews_list.dart';

class ReviewsPage extends StatelessWidget {
  final ElderlyPerson person;

  const ReviewsPage({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('รีวิวและคะแนน'),
        centerTitle: true,
        backgroundColor: const Color(0xFF8BC34A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Summary Card
            RatingSummaryCard(
              name: person.displayName,
              rating: person.rating,
              reviewCount: person.reviewCount,
            ),
            const SizedBox(height: 16),
            
            // Reviews List
            ReviewsList(person: person),
          ],
        ),
      ),
    );
  }
}