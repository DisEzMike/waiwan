import 'package:flutter/material.dart';
import '../../widgets/user_profile/edit_profile_image.dart';
import '../../widgets/user_profile/profile_form.dart';
import '../../widgets/user_profile/save_button.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FEE7),
      appBar: AppBar(
        backgroundColor:Color.fromRGBO(110, 183, 21, 95),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        centerTitle: true,
        title: const Text(
          'แก้ไขข้อมูลส่วนตัว',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                name: 'นายกาย',
                phoneNumber: '028-264-1234',
                address: '999/99 ฉลองกรุง 1 แขวงลาดกระบัง เขตลาดกระบัง กรุงเทพมหานคร 10520',
                onNameChanged: (value) {
                  // TODO: Handle name change
                  print('Name changed: $value');
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
