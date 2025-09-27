import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/model/user.dart';
import 'package:waiwan/services/user_service.dart';
import 'edit_profile.dart';
import '../../widgets/user_profile/profile_header.dart';
import '../../widgets/user_profile/menu_items.dart';

class ContractorProfile extends StatefulWidget {
  const ContractorProfile({super.key});

  @override
  State<ContractorProfile> createState() => _ContractorProfileState();
}

class _ContractorProfileState extends State<ContractorProfile> {
  final String _token = localStorage.getItem('token') ?? '';
  User? _user = null;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final res = await UserService(accessToken: _token).getProfile();
    if (res != null && mounted) {
      setState(() {
        // Update user state with fetched profile data
        _user = User.fromJson(res);
      });
    }
  }

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
                      name: '${_user?.displayName}',
                      subtitle: 'แก้ไขข้อมูลส่วนตัว',
                      imageAsset: 'assets/images/guy.png',
                      onEditPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(user: _user!),
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
