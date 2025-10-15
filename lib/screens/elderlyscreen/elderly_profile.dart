import 'package:flutter/material.dart';
import 'package:waiwan/screens/create_job_screen.dart';
import '../../model/elderly_person.dart';
import 'chat.dart';
import 'reviews.dart';
import '../nav_bar.dart';
import '../../widgets/elderly_profile/profile_card.dart';
import '../../widgets/elderly_profile/chat_button.dart';
// info sections are now rendered inside a Card

class ElderlyProfilePage extends StatefulWidget {
  final ElderlyPerson person;
  String? q = "";

  ElderlyProfilePage({super.key, required this.person, this.q});

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
          ProfileCard(
            person: widget.person,
            onRatingTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewsPage(person: widget.person),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Chat Button
          ChatButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CreateJobScreen(
                          seniorId: widget.person.id,
                          query: widget.q,
                        ),
                  ),
                ),
          ),
          const SizedBox(height: 16),

          // Information card: phone, abilities, work experience, chronic diseases
          Card(
            color: const Color.fromARGB(255, 255, 255, 255), // pale green background
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            margin: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _infoTile(title: 'เบอร์โทรศัพท์', content: widget.person.profile.phone),
                Divider(height: 1, thickness: 1, color: const Color.fromARGB(255, 161, 158, 158)),
                _infoTile(title: 'ความสามารถ', content: widget.person.ability.otherAbility),
                Divider(height: 1, thickness: 1, color: const Color.fromARGB(255, 161, 158, 158)),
                _infoTile(title: 'อาชีพที่เคยทำ', content: widget.person.ability.workExperience),
                Divider(height: 1, thickness: 1, color: const Color.fromARGB(255, 161, 158, 158)),
                _infoTile(title: 'โรคประจำตัว', content: widget.person.profile.chronicDiseases),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.isEmpty ? '-' : content,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
          backgroundColor: const Color(0xFF6EB715), // Green color from mockup
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
            const Center(
              child: Text('หน้าข้อความ', style: TextStyle(fontSize: 18)),
            ), // หน้าข้อความ
            const Center(
              child: Text('หน้าแจ้งเตือน', style: TextStyle(fontSize: 18)),
            ), // หน้าแจ้งเตือน
            const Center(
              child: Text('หน้าโปรไฟล์', style: TextStyle(fontSize: 18)),
            ), // หน้าโปรไฟล์
          ],
        ),
      ),
    );
  }
}
