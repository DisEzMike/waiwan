import 'package:flutter/material.dart';
import 'package:waiwan/components/bottom_appbar.dart';

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
      label: 'โปรไฟล์',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          _currentTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),
        ),
      ),
      body: Scaffold(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        destinations: destinations
            .map<NavigationDestination>(
              (Destination destination) => NavigationDestination(
                icon: Icon(
                  destination.icon,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                selectedIcon: Icon(
                  destination.iconSelected,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: destination.label,
              ),
            )
            .toList(),
        selectedIndex: _currentIndex,
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
            _currentTitle = destinations[index].label;
          });
        },
      ),
    );
  }
}
