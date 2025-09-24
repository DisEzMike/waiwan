import 'package:flutter/material.dart';

class Destination {
  final IconData icon;
  final IconData iconSelected;
  final String label;
  const Destination({
    required this.icon,
    required this.iconSelected,
    required this.label,
  });
}

class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key});
  final String title = 'หน้าแรก';

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  int _currentIndex = 0;
  String _currentTitle = 'หน้าแรก';

  static const List<Destination> destinations = <Destination>[
    Destination(
      icon: Icons.home_outlined,
      iconSelected: Icons.home,
      label: 'หน้าแรก',
    ),
    Destination(
      icon: Icons.message_outlined,
      iconSelected: Icons.message,
      label: 'ข้อความ',
    ),
    Destination(
      icon: Icons.notifications_outlined,
      iconSelected: Icons.notifications,
      label: 'แจ้งเตือน',
    ),
    Destination(
      icon: Icons.person_outlined,
      iconSelected: Icons.person,
      label: 'โปรไฟ',
    ),
  ];

  Widget _homePage(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
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
                hintText: 'ค้นหา',
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

            // ปุ่มคูปอง + คะแนน
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(color: Colors.black, height: 0.5);
            }
            return const TextStyle(color: Colors.white, height: 0.5);
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(size: 30, color: Colors.black);
            }
            return const IconThemeData(size: 30, color: Colors.white);
          }),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _currentTitle,
          style: TextStyle(
            color: onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homePage(context),
          const Center(child: Text('หน้าข้อความ')),
          const Center(child: Text('หน้าแจ้งเตือน')),
          const Center(child: Text('หน้าโปรไฟล์')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          indicatorColor: Colors.transparent,
          height: 70,
          destinations: destinations.map((d) {
            return NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.iconSelected),
              label: d.label,
            );
          }).toList(),
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
              _currentTitle = destinations[index].label;
            });
          },
      ),
    ),
    );
  }
}
