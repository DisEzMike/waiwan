import 'package:flutter/material.dart';
import 'elderlypersonclass.dart';
import 'chat.dart';
import 'reviews.dart';
import '../nav_bar.dart';

class ElderlyProfilePage extends StatefulWidget {
  final ElderlyPerson person;

  const ElderlyProfilePage({
    super.key,
    required this.person,
  });

  @override
  State<ElderlyProfilePage> createState() => _ElderlyProfilePageState();
}

class _ElderlyProfilePageState extends State<ElderlyProfilePage> {
  int _currentIndex = 0;
  String _currentTitle = 'โปรไฟล์ผู้รับจ้าง';

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
      _currentTitle = AppDestinations.destinations[index].label;
    });
    
    // If home button is pressed (index 0), navigate back to main screen
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card with Green Background
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8BC34A), Color(0xFF7CB342)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Circle profile image
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    widget.person.imageUrl,
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
                              widget.person.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (widget.person.isVerified)
                            const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Rating - Tappable
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewsPage(person: widget.person),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              widget.person.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.person.reviewCount} รีวิว)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
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
          ),
          const SizedBox(height: 16),
          
          // Chat Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(person: widget.person),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'แชทเพื่อเสนองาน',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // มือถือ Section
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'มือถือ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '0${widget.person.phoneNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          
          // ความสามารถ Section
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ความสามารถ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.person.ability,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          
          // อายุที่ถนัด Section  
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'อาชีพที่เคยทำ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.person.isVerified)
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(ได้รับการรับรอง)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.person.workExperience,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          
          // โรคประจำตัว Section
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'โรคประจำตัว',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.person.chronicDiseases,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Colors.black, height: 0.5);
            }
            return const TextStyle(color: Colors.white, height: 0.5);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(size: 30, color: Colors.black);
            }
            return const IconThemeData(size: 30, color: Colors.white);
          }),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Light gray background
        appBar: AppBar(
          title: Text(_currentTitle),
          centerTitle: true,   
          backgroundColor: const Color(0xFF8BC34A), // Green color from mockup
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildProfileContent(), // โปรไฟล์ผู้รับจ้าง
            const Center(child: Text('หน้าข้อความ', style: TextStyle(fontSize: 18))), // หน้าข้อความ
            const Center(child: Text('หน้าแจ้งเตือน', style: TextStyle(fontSize: 18))), // หน้าแจ้งเตือน
            const Center(child: Text('หน้าโปรไฟล์', style: TextStyle(fontSize: 18))), // หน้าโปรไฟล์
          ],
        ),
        bottomNavigationBar: AppNavigationBar(
          destinations: AppDestinations.destinations,
          selectedIndex: _currentIndex,
          onDestinationSelected: _handleNavigation,
        ),
      ),
    );

  }
}