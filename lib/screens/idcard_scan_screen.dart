import 'package:flutter/material.dart';
import 'package:waiwan/screens/personal_info_screen.dart';

class IdCardScanScreen extends StatelessWidget {
  const IdCardScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12.0);
    return Scaffold(
      backgroundColor: const Color(0xFFF3FDEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6EB715),
        title: const Text('ถ่ายบัตรประชาชน'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // simulated camera feed background
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: borderRadius,
                      ),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: borderRadius,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // dark background to simulate camera preview
                              Container(color: Colors.black87),
                              // framed overlay
                              Center(
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  // put a placeholder ID image in the middle
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image.asset(
                                      'assets/images/p.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // scanning hint text
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    'วางบัตรในกรอบแล้วกดยืนยัน',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.9),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // round capture button at bottom center (overlay)
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // retake / refresh - for now just show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ถ่ายใหม่ (จำลอง)')),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('ถ่ายใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Confirm -> navigate to face scan screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('ยืนยัน'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EB715),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}