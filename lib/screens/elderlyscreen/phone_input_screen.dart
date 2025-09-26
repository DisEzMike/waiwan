import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    // phoneController is already filtered to digits only by inputFormatters
    final digits = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final valid = digits.length == 10;
    if (valid != _isPhoneValid) {
      setState(() {
        _isPhoneValid = valid;
      });
    }
  }

  @override
  void dispose() {
    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = const Color(0xFFF3FDEC); // very light green
    return Scaffold(
      // make the screen itself light green like the card in design
      backgroundColor: cardColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            // On mobile we want full-screen style: input and button centered vertically
            if (isMobile) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'เบอร์โทร',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: '0812345678',
                          hintStyle: TextStyle(color: Colors.black26),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isPhoneValid
                                  ? () {
                                    final phone = phoneController.text.trim();
                                    Navigator.pushNamed(
                                      context,
                                      '/otp',
                                      arguments: phone,
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EB715),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('ต่อไป'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // On larger screens keep a centered card
            return Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 420,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'เบอร์โทร',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          hintText: '0812345678',
                          hintStyle: TextStyle(color: Colors.black26),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isPhoneValid
                                  ? () {
                                    final phone = phoneController.text.trim();
                                    Navigator.pushNamed(
                                      context,
                                      '/otp',
                                      arguments: phone,
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EB715),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('ต่อไป'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
