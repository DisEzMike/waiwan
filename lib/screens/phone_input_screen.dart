import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import 'package:waiwan/screens/main_screen.dart';
import 'package:waiwan/services/auth_service.dart';
import 'package:waiwan/utils/font_size_helper.dart';
import 'otp_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    final token = localStorage.getItem('token') ?? '';
    if (token.isNotEmpty) {
      // User is already logged in, navigate to main screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyMainPage()),
          (route) => false,
        );
      });
    }

    phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    // Check if phone number has exactly 10 digits
    final digits = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final valid = digits.length == 10;
    if (valid != _isPhoneValid) {
      setState(() {
        _isPhoneValid = valid;
      });
    }
  }

  Future<void> _submitPhoneNumber() async {
    final phoneNumber = phoneController.text;

    try {
      final res = await AuthService.requestOtp(phoneNumber);
      SnackBar snackBar = SnackBar(
        content: Text(res['message']),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: phoneNumber)),
      );
    } catch (e) {
      // Show error dialog
      SnackBar snackBar = SnackBar(
        content: Text('Error: $e'),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

  }

  @override
  void dispose() {
    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();
    _focusNode.dispose();
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
                      Text(
                        'เข้าสู่ระบบ',
                        style: FontSizeHelper.createTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'เบอร์โทร',
                        style: FontSizeHelper.createTextStyle(
                          fontSize: 14, 
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _focusNode.requestFocus();
                        },
                        child: TextField(
                          controller: phoneController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          enabled: true,
                          readOnly: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: FontSizeHelper.createTextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF6EB715),
                                width: 2,
                              ),
                            ),
                            hintText: '0812345678',
                            hintStyle: const TextStyle(color: Colors.black26),
                            prefixIcon: const Icon(Icons.phone),
                            counterText: '',
                          ),
                          onTap: () {
                            _focusNode.requestFocus();
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPhoneValid ? _submitPhoneNumber : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EB715),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'ต่อไป',
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
                      Text(
                        'เข้าสู่ระบบ',
                        style: FontSizeHelper.createTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'เบอร์โทร',
                        style: FontSizeHelper.createTextStyle(
                          fontSize: 14, 
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _focusNode.requestFocus();
                        },
                        child: TextField(
                          controller: phoneController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          enabled: true,
                          readOnly: false,
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF6EB715),
                                width: 2,
                              ),
                            ),
                            hintText: '0812345678',
                            hintStyle: FontSizeHelper.createTextStyle(
                              fontSize: 16,
                              color: Colors.black26,
                            ),
                            prefixIcon: const Icon(Icons.phone),
                            counterText: '',
                          ),
                          onTap: () {
                            _focusNode.requestFocus();
                          },
                          // onChanged: (value) {
                          //   debugPrint(
                          //     'Phone input changed: $value',
                          //   ); // Debug print
                          // },
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              () => _isPhoneValid ? _submitPhoneNumber() : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EB715),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'ต่อไป',
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
            );
          },
        ),
      ),
    );
  }
}
