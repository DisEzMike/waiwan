import 'package:flutter/material.dart';
import 'package:waiwan/screens/chat_rooms_screen.dart';
import 'elderlyscreen/elderly_screen.dart';
import 'nav_bar.dart';
import 'profilescreen/contractor_profile.dart';
import 'notificationscreen/notification.dart';
// Make sure the class name in contractor_profile.dart matches 'ContractorProfilePage'

class MyMainPage extends StatelessWidget {
  const MyMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = AppDestinations.destinations;

    return NavBarWrapper(
      items: [
        AppNavItem(
          destination: destinations[0],
          builder: (context) => const ElderlyScreen(),
        ),
        AppNavItem(
          destination: destinations[1],
          builder: (context) => ChatRoomsScreen(),
        ),
        AppNavItem(
          destination: destinations[2],
          builder: (context) => const NotificationScreen(),
        ),
        AppNavItem(
          destination: destinations[3],
          builder: (context) => ContractorProfile(),
        ),
      ],
    );
  }
}
