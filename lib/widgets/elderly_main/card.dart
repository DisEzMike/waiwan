import 'package:flutter/material.dart';
import '../../model/elderly_person.dart';

class ElderlyPersonCard extends StatelessWidget {
  final ElderlyPerson person;
  final VoidCallback? onTap;

  const ElderlyPersonCard({
    super.key,
    required this.person,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    const TextStyle cardBoldTextStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(204, 239, 178, 100),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
              // child: Image.network(  <-- if use api use this
                person.imageUrl,
                height: 174,
                width: 248,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 174,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row
                  Row(
                    children: [
                      Text(
                        'ชื่อ: ',
                        style: cardBoldTextStyle,
                      ),
                      Expanded(
                        child: Text(
                          person.name,
                          style: cardBoldTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (person.isVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 26,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Distance row
                  Row(
                    children: [
                      Text(
                        'ระยะห่าง: ',
                        style: cardBoldTextStyle,
                      ),
                      Text(
                        person.distance,
                        style: cardBoldTextStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Ability row
                  Row(
                    children: [
                      Text(
                        'ความสามารถ: ',
                        style: cardBoldTextStyle,
                      ),
                      Expanded(
                        child: Text(
                          person.ability,
                          style: cardBoldTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
