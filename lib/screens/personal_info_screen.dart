import 'package:flutter/material.dart';
// confirmation flow removed — keep this screen purely for editing/display
import 'package:waiwan/utils/font_size_helper.dart';
import 'package:waiwan/widgets/input_field.dart';

class PersonalInfoScreen extends StatefulWidget {
  // expects arguments: Map<String, String> with parsed id info
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // controllers for fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _idAddressController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, String>) {
      // fill controllers from parsed id info when available
      _nameController.text = args['name'] ?? '';
      _surnameController.text = args['surname'] ?? '';
      _idCardController.text = args['id_card'] ?? '';
      _idAddressController.text = args['id_address'] ?? '';
      _currentAddressController.text = args['current_address'] ?? '';
      _phoneController.text = args['phone'] ?? '';
      _genderController.text = args['gender'] ?? '';
    } else {
      // Demo fallback so opening /personal_info directly shows example data
      _nameController.text = 'สมชาย';
      _surnameController.text = 'ใจดี';
      _idCardController.text = '1-2345-67890-12-3';
      _idAddressController.text =
          '123/45 หมู่ 6 ต.ตัวอย่าง อ.ตัวอย่าง จ.ตัวอย่าง 12345';
      _currentAddressController.text =
          '456 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพมหานคร 10110';
      _phoneController.text = '0812345678';
      _genderController.text = 'ชาย';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _idAddressController.dispose();
    _currentAddressController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  // personal info submit flow removed; this screen is for display/edit only

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FDEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EB715),
        title: Text(
          'ข้อมูลส่วนตัว',
          style: FontSizeHelper.createTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField('ชื่อ', _nameController),
                buildTextField('นามสกุล', _surnameController),
                buildTextField('เลขบัตรประชาชน', _idCardController),
                buildTextField(
                  'ที่อยู่ตามบัตรประชาชน',
                  _idAddressController,
                  maxLines: 4,
                ),
                buildTextField(
                  'ที่อยู่ปัจจุบัน',
                  _currentAddressController,
                  maxLines: 4,
                ),
                buildTextField('เบอร์โทร', _phoneController),
                buildTextField('เพศ', _genderController),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile-upload');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EB715),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('ยืนยัน'),
                    ),
                  ),
                ),
                // Note: confirmation button intentionally removed —
                // user may upload profile photo independently.
              ],
            ),
          ),
        ),
      ),
    );
  }
}
