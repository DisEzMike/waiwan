import 'package:flutter/material.dart';
import 'profile_form_field.dart';

class ProfileForm extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String address;
  final Function(String)? onNameChanged;
  final Function(String)? onPhoneChanged;
  final Function(String)? onAddressChanged;

  const ProfileForm({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.onNameChanged,
    this.onPhoneChanged,
    this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileFormField(
            label: 'ชื่อ',
            initialValue: name,
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 16),
          ProfileFormField(
            label: 'เบอร์โทร',
            initialValue: phoneNumber,
            onChanged: onPhoneChanged,
          ),
          const SizedBox(height: 16),
          ProfileFormField(
            label: 'ที่อยู่',
            initialValue: address,
            maxLines: 3,
            onChanged: onAddressChanged,
          ),
        ],
      ),
    );
  }
}