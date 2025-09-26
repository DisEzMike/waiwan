import 'package:flutter/material.dart';
import 'edit_profile.dart';
import '../../widgets/user_profile/profile_header.dart';
import '../../widgets/user_profile/menu_items.dart';

class ContractorProfile extends StatelessWidget {
  const ContractorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FEE7),
      body: SafeArea(
        child: Column(
          children: [
            // Profile card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2FEE7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Profile info section
                    ProfileHeader(
                      name: 'นายกาย',
                      subtitle: 'แก้ไขข้อมูลส่วนตัว',
                      imageAsset: 'assets/images/guy.png',
                      onEditPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfile(),
                          ),
                        );
                      },
                    ),
                    // Menu Items
                    const MenuItems(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
