import 'package:flutter/material.dart';
import '../../model/elderly_person.dart';

class ProfileCard extends StatelessWidget {
  final ElderlyPerson person;
  final VoidCallback onRatingTap;

  const ProfileCard({
    super.key,
    required this.person,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFDFF7D9), // pale green (solid)
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Circle profile image
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              person.profile.imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Name and Rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        person.displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF388B12),
                        ),
                      ),
                    ),
                    if (person.isVerified)
                      Icon(
                        Icons.verified,
                        color: Colors.blue[600],
                        size: 29,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating - Tappable
                GestureDetector(
                  onTap: onRatingTap,
                  child: Row(
                    children: [
                      Text(
                        person.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon( Icons.star, color: Colors.orange, size: 16),
                      Text(
                        '(${person.reviewCount} รีวิว)',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6D6D6D),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF6D6D6D),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}