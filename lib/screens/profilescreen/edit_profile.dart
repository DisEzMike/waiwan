import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waiwan/model/user.dart';
import 'package:waiwan/services/user_service.dart';
import 'package:waiwan/utils/helper.dart';
import '../../widgets/user_profile/edit_profile_image.dart';
import '../../widgets/user_profile/profile_form.dart';
import '../../widgets/user_profile/save_button.dart';

class EditProfile extends StatefulWidget {
  final User user;
  const EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // controllers for fields
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  // final TextEditingController _idCardController = TextEditingController();
  // final TextEditingController _idAddressController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  // final TextEditingController _genderController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  File? _cropedImage;
  Uint8List? _pickedBytes;

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
    _currentAddressController.text = profile.current_address;
    _phoneController.text = profile.phone;
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

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _pickedImage = photo;
          _pickedBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ไม่สามารถเลือกภาพได้: $e')));
      }
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    try {
      CroppedFile? croppedImg = await ImageCropper().cropImage(
        maxWidth: 512,
        maxHeight: 512,
        sourcePath: imageFile.path,
        compressQuality: 100,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [WebUiSettings(context: context)],
      );
      if (croppedImg == null) {
        return null;
      } else {
        return File(croppedImg.path);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> _pickImg() async {
    await _pickFromGallery();
    if (_pickedImage != null && _pickedBytes != null) {
      final crop = await _cropImage(imageFile: File(_pickedImage!.path));
      if (crop != null) {
        final bytes = await crop.readAsBytes();
        setState(() {
          _cropedImage = crop;
          _pickedBytes = bytes;
        });
      }
    }
  }

  Future<void> _onConfirm() async {
    if (_cropedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกรูปก่อนกดยืนยัน')),
      );
      return;
    }

    final File file = File(_cropedImage!.path);
    UserService().uploadProfileImage(file).catchError((e) {
      if (mounted) {
        showErrorSnackBar(context, 'อัพโหลดรูปไม่สำเร็จ');
      }
      debugPrint('Context is not mounted. Cannot show error SnackBar.');
    });

    if (mounted) {
      showSuccessSnackBar(context, 'อัพโหลดรูปสำเร็จ');
    } else {
      debugPrint('Context is not mounted. Cannot show success SnackBar.');
    }
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
                imageAsset: widget.user.profile.imageUrl!,
                onEditPressed: () async {
                  await _pickImg();
                  if (_cropedImage != null && mounted) {
                    await _onConfirm();
                    Timer(
                      Duration(milliseconds: 500),
                      () => Navigator.pop(context),
                    );
                  }
                },
              ),

              // Form Section
              ProfileForm(
                name:
                    '${_firstnameController.text} ${_lastnameController.text}',
                phoneNumber: _phoneController.text,
                address: _currentAddressController.text,
                onNameChanged: (value) {
                  debugPrint('Name changed: $value');
                  final name = value.split(' ');
                  if (name.isNotEmpty) {
                    _firstnameController.text = name[0];
                    if (name.length > 1) {
                      _lastnameController.text = name.sublist(1).join(' ');
                    }
                  }
                },
                onPhoneChanged: (value) {
                  debugPrint('Phone changed: $value');
                },
                onAddressChanged: (value) {
                  debugPrint('Address changed: $value');
                },
              ),

              // Save Button
              SaveButton(
                onPressed: () {
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
