import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:waiwan/screens/face_scan.dart';
import 'package:waiwan/screens/main_screen.dart';
import 'package:waiwan/services/auth_service.dart';
import 'package:waiwan/utils/font_size_helper.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _maskedPhone(BuildContext context) {
    final phone = widget.phoneNumber;
    if (phone.isEmpty) return '';
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      final last4 = digits.substring(digits.length - 4);
      return 'xxx-xxx-$last4';
    }
    return phone;
  }

  bool get _isComplete => _controllers.every((c) => c.text.trim().isNotEmpty);

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _focusNodes.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  Future<void> _submitOTP() async {
    final phone = widget.phoneNumber;
    final otp = _controllers.map((c) => c.text).join();
    print('Submitted OTP: $otp');

    // // TODO: validate OTP with backend
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder:
    //         (context) => const PersonalInfoScreen(),
    //   ),
    // );

    try {
      final res = await AuthService.verifyOtp(phone, otp);
      if (!res['is_new']) {
        final resp = await AuthService.authentication(res['auth_code'], {});
        localStorage.setItem('user_data', resp['user_data'].toString());
        localStorage.setItem('token', resp['access_token'].toString());

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyMainPage()),
          (route) => false,
        );
      } else {
        localStorage.setItem('is_new', "${res['is_new']}");
        localStorage.setItem("auth_code", res['auth_code']);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FaceScanScreen()),
        );
      }
    } catch (e) {
      print(e);
      SnackBar snackBar = SnackBar(
        content: Text('OTP ไม่ถูกต้อง หรือหมดอายุ'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // backspace handling is done inline in KeyboardListener onKeyEvent

  @override
  Widget build(BuildContext context) {
    final cardColor = const Color(0xFFF3FDEC);
    final masked = _maskedPhone(context);
    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'ยืนยันเบอร์โทรศัพท์',
          style: FontSizeHelper.createTextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ป้อนรหัส OTP',
                  style: FontSizeHelper.createTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'กรุณากรอกรหัส 4 หลักที่ส่งไปยังโทรศัพท์ของคุณ',
                  style: FontSizeHelper.createTextStyle(
                    fontSize: 16, 
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (masked.isNotEmpty) ...[
                  Text(
                    'รหัสถูกส่งไปยัง $masked',
                    style: FontSizeHelper.createTextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Text(
                    'ตรวจสอบ SMS ในโทรศัพท์ของคุณ',
                    style: FontSizeHelper.createTextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (i) {
                    return SizedBox(
                      width: 64,
                      height: 64,
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (e) {
                          // handle Backspace
                          if (e is KeyDownEvent) {
                            final key = e.logicalKey;
                            if (key == LogicalKeyboardKey.backspace &&
                                _controllers[i].text.isEmpty) {
                              if (i > 0) {
                                _focusNodes[i - 1].requestFocus();
                                _controllers[i - 1].clear();
                              }
                            }
                          }
                        },
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF6EB715),
                                width: 2.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2.0,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged:
                              (v) => setState(() {
                                _onChanged(i, v);
                              }),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // TODO: resend logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ส่งรหัสใหม่ (จำลอง)')),
                    );
                  },
                  child: Text(
                    'ส่งรหัสยืนยันอีกครั้ง',
                    style: FontSizeHelper.createTextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isComplete ? _submitOTP : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EB715),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
