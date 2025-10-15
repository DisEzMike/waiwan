import 'package:flutter/material.dart';

class MyBottomAppBar extends StatefulWidget {
  const MyBottomAppBar({super.key});

  @override
  State<MyBottomAppBar> createState() => _MyBottomAppBarState();
}

class _MyBottomAppBarState extends State<MyBottomAppBar> {
  int currentIndex = 0;
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
      icon: Icons.work_outline,
      iconSelected: Icons.work,
      label: 'งาน',
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
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        destinations:
            destinations
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
        selectedIndex: currentIndex,
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class Destination {
  final IconData icon;
  final IconData iconSelected;
  final String label;
  const Destination({
    required this.icon,
    required this.label,
    required this.iconSelected,
  });
}
