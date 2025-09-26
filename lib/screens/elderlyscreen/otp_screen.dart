import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

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
    final args = ModalRoute.of(context)?.settings.arguments;
    final phone = (args is String && args.isNotEmpty) ? args : '';
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
        title: const Text(
          'ยืนยันเบอร์โทรศัพท์',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (masked.isNotEmpty) ...[
                  Text(
                    'รหัสถูกส่งไปยัง $masked',
                    style: const TextStyle(color: Colors.black87),
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
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
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
                  child: const Text(
                    'ส่งรหัสยืนยันอีกครั้ง',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isComplete
                            ? () {
                              // TODO: validate OTP with backend
                              Navigator.pushNamed(context, '/idcard');
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
