import 'package:flutter/material.dart';
import 'package:waiwan/model/user.dart';
import '../../widgets/user_profile/edit_profile_image.dart';
import '../../widgets/user_profile/profile_form.dart';
import '../../widgets/user_profile/save_button.dart';

class EditProfile extends StatefulWidget {
  final User user;
  EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  // controllers for fields
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  // final TextEditingController _idCardController = TextEditingController();
  // final TextEditingController _idAddressController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  // final TextEditingController _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() {
    // Load user data into controllers
    final user = widget.user;
    final profile = user.profile;

    final names = user.displayName.split(' ');
    if (names.isNotEmpty) {
      _firstnameController.text = names[0];
      if (names.length > 1) {
        _lastnameController.text = names.sublist(1).join(' ');
      }
    }

    // _idCardController.text = profile.idCard ?? '';
    // _idAddressController.text = profile.idAddress ?? '';
    _currentAddressController.text = profile.current_address ?? '';
    _phoneController.text = profile.phone ?? '';
    // _genderController.text
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _currentAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FEE7),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(110, 183, 21, 95),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        centerTitle: true,
        title: const Text(
          'แก้ไขข้อมูลส่วนตัว',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Image Section
              EditProfileImage(
                imageAsset: 'assets/images/guy.png',
                onEditPressed: () {
                  // TODO: Implement image selection
                  print('Edit profile image pressed');
                },
              ),

              // Form Section
              ProfileForm(
                name:
                    '${_firstnameController.text} ${_lastnameController.text}',
                phoneNumber: '${_phoneController.text}',
                address: '${_currentAddressController.text}',
                onNameChanged: (value) {
                  // TODO: Handle name change
                  print('Name changed: $value');
                  final name = value.split(' ');
                  if (name.isNotEmpty) {
                    _firstnameController.text = name[0];
                    if (name.length > 1) {
                      _lastnameController.text = name.sublist(1).join(' ');
                    }
                  }
                },
                onPhoneChanged: (value) {
                  // TODO: Handle phone change
                  print('Phone changed: $value');
                },
                onAddressChanged: (value) {
                  // TODO: Handle address change
                  print('Address changed: $value');
                },
              ),

              // Save Button
              SaveButton(
                onPressed: () {
                  // TODO: Implement save functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('บันทึกข้อมูลเรียบร้อย'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
