import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import 'package:waiwan/utils/font_size_helper.dart';
import '../../model/elderly_person.dart';

class ElderlyPersonCard extends StatelessWidget {
  final ElderlyPerson person;
  final VoidCallback? onTap;

  const ElderlyPersonCard({super.key, required this.person, this.onTap});

  @override
  Widget build(BuildContext context) {
    TextStyle cardTextStyle = FontSizeHelper.createTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
    );

    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
                  child: Image.network(
                    // child: Image.network(  <-- if use api use this
                    person.profile.imageUrl,
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
                          Expanded(
                            child: Text(
                              person.displayName,
                              style: cardTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
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
                      Row(
                        children: [
                          Text(
                            'ระยะห่าง: ',
                            style: cardTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            person.distance!,
                            style: cardTextStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Text(
                        'ความสามารถ',
                        style: cardTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        person.ability.otherAbility,
                        style: cardTextStyle,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
