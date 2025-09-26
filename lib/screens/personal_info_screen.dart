import 'package:flutter/material.dart';
import 'idcard_scan_screen.dart';

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
  final TextEditingController _idAddressController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, String>) {
      // fill controllers from parsed id info when available
      _nameController.text = args['name'] ?? '';
      _surnameController.text = args['surname'] ?? '';
      _idAddressController.text = args['id_address'] ?? '';
      _currentAddressController.text = args['current_address'] ?? '';
      _phoneController.text = args['phone'] ?? '';
      _genderController.text = args['gender'] ?? '';
    } else {
      // Demo fallback so opening /personal_info directly shows example data
      _nameController.text = 'สมชาย';
      _surnameController.text = 'ใจดี';
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
    _medicalController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // proceed to ID card scan step
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const IdCardScanScreen(),
        ),
      );
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('ข้อมูลส่วนตัว'),
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
                _buildField('โรคประจำตัว', _medicalController),
                _buildField('ชื่อผู้ที่ติดต่อได้', _contactNameController),
                _buildField('เบอร์ผู้ที่ติดต่อได้', _contactPhoneController),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EB715),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('ยืนยัน'),
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