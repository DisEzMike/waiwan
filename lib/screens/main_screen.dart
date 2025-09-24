import 'package:flutter/material.dart';
import 'elderlyscreen/elderly_screen.dart';
import 'profilescreen/contractor_profile.dart';

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
      label: 'โปรไฟล์',
    ),
  ];

  Widget _homePage(BuildContext context) {
    return const ElderlyScreen();
  }

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,    // Center the title
        title: Text(
          _currentTitle,
          style: TextStyle(
            color: onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homePage(context),
          const Center(child: Text('หน้าข้อความ')),
          const Center(child: Text('หน้าแจ้งเตือน')),
          const ContractorProfile(),
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
