import 'package:flutter/material.dart';
import 'demo_data.dart';
import 'card.dart';

class ElderlyScreen extends StatelessWidget {
  const ElderlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SearchBar(
                hintText: 'พบกล่อง',
                leading: const Icon(Icons.search, size: 30),
                constraints: const BoxConstraints(
                  maxHeight: 60,
                  minHeight: 50,
                ),
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 24.0),
                ),
                hintStyle: WidgetStatePropertyAll<TextStyle>(
                  TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                elevation: const WidgetStatePropertyAll<double>(1.0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      foregroundColor: const Color(0xFF000000),
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Image.asset('assets/images/coupon.png', width: 24, height: 24),
                    label: const Text(
                      'ดูปองของฉัน',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green[100],
                      foregroundColor: const Color(0xFF000000),
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Image.asset('assets/images/p.png', width: 24, height: 24),
                    label: const Text(
                      '1000 คะแนน',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: demoElderlyPersons.length,
              itemBuilder: (context, index) {
                final person = demoElderlyPersons[index];
                return ElderlyPersonCard(
                  person: person,
                  onTap: () {
                    // Handle card tap
                    print('Tapped on ${person.name}');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}