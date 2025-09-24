import 'package:flutter/material.dart';

class ElderlyPerson {
  final String name;
  final String distance;
  final String ability;
  final String imageUrl;
  final bool isVerified;

  ElderlyPerson({
    required this.name,
    required this.distance,
    required this.ability,
    required this.imageUrl,
    this.isVerified = false,
  });
}

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
                    color: Colors.black.withOpacity(0.1),
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
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 24.0),
                ),
                hintStyle: MaterialStatePropertyAll<TextStyle>(
                  TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                elevation: const MaterialStatePropertyAll<double>(1.0),
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
                      shadowColor: Colors.black.withOpacity(0.3),
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
                      shadowColor: Colors.black.withOpacity(0.3),
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
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: demoElderlyPersons.length,
              itemBuilder: (context, index) {
                final person = demoElderlyPersons[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          person.imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
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
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'ชื่อ: ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Expanded(
                                  child: Text(
                                    person.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (person.isVerified)
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  'ระยะห่าง: ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  person.distance,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  'ความสามารถ: ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Expanded(
                                  child: Text(
                                    person.ability,
                                    style: const TextStyle(fontSize: 14),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final List<ElderlyPerson> demoElderlyPersons = [
  ElderlyPerson(
    name: 'นายสมชาย ที่หนึ่งเท่านั้น',
    distance: '500 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'https://example.com/elderly1.jpg',
    isVerified: true,
  ),
  ElderlyPerson(
    name: 'นายภาส',
    distance: '600 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'https://example.com/elderly2.jpg',
  ),
  ElderlyPerson(
    name: 'นายคันนายน์',
    distance: '500 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'https://example.com/elderly3.jpg',
  ),
  ElderlyPerson(
    name: 'นางน้อน',
    distance: '450 m.',
    ability: 'พูดกล่อง',
    imageUrl: 'https://example.com/elderly4.jpg',
    isVerified: true,
  ),
];