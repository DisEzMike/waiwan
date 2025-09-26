import 'package:flutter/material.dart';
import 'package:waiwan/screens/elderlyscreen/phone_input_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/Untitled_Artwork 1.png",
              height: 250,
            ), // รูปปู่ย่า (ปรับเป็นไฟล์ที่มีอยู่)
            const SizedBox(height: 16),
            const Text(
              "ไหว้วาน",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneInputScreen()),
                );
              },
              child: const Text("เริ่มต้นใช้งาน"),
            ),
            // ...existing code...
          ],
        ),
      ),
    );
  }
}
