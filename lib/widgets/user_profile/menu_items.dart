import 'package:flutter/material.dart';
import 'menu_item.dart';
import '../../screens/settings_screen.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          MenuItem(
            title: 'การตั้งค่า',
            icon: Icons.settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const MenuItem(
            title: 'การชำระเงิน',
            icon: Icons.payment,
          ),
          const MenuItem(
            title: 'ประวัติการงาน',
            icon: Icons.work_history,
          ),
          const MenuItem(
            title: 'ศูนย์ของความช่วยเหลือ',
            icon: Icons.help,
          ),
          const MenuItem(
            title: 'นโยบาย',
            icon: Icons.policy,
            showDivider: false, // Last item doesn't need divider
          ),
        ],
      ),
    );
  }
}