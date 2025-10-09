import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/screens/main_screen.dart';
import 'package:waiwan/services/auth_service.dart';
import 'package:waiwan/utils/font_size_helper.dart';

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

  void _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final payload = {
        'profile': {
          'first_name': _nameController.text.trim(),
          'last_name': _surnameController.text.trim(),
          'id_card': _idCardController.text.trim(),
          'id_address': _idAddressController.text.trim(),
          'current_address': _currentAddressController.text.trim(),
          'phone': _phoneController.text,
          'gender': _genderController.text,
        }
      };

      try {
        // send to backend
        final auth_code = localStorage.getItem("auth_code");
        final resp = await AuthService.authentication(auth_code!, payload);
        localStorage.setItem('user_data', resp['user_data'].toString());
        localStorage.setItem('token', resp['access_token'].toString());

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MyMainPage()),
          (route) => false,
        );

      } catch (e) {
        // handle error
        print('Error submitting personal info: $e');
      }
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
      //   (route) => false,
      // );
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: FontSizeHelper.createTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator:
              (v) => (v == null || v.trim().isEmpty) ? 'กรุณาใส่ข้อมูล' : null,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

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
                _buildField('ชื่อ', _nameController),
                _buildField('นามสกุล', _surnameController),
                _buildField('เลขบัตรประชาชน', _idCardController),
                _buildField(
                  'ที่อยู่ตามบัตรประชาชน',
                  _idAddressController,
                  maxLines: 4,
                ),
                _buildField(
                  'ที่อยู่ปัจจุบัน',
                  _currentAddressController,
                  maxLines: 4,
                ),
                _buildField('เบอร์โทร', _phoneController),
                _buildField('เพศ', _genderController),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EB715),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'ยืนยัน',
                      style: FontSizeHelper.createTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
