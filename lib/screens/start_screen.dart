import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'phone_input_screen.dart';
import '../providers/font_size_provider.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF6EB715),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Title
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "ไหว้",
                      style: GoogleFonts.kanit(
                        fontSize: 90,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3C2F14),
                      ),
                    ),
                    TextSpan(
                      text: "วาน",
                      style: GoogleFonts.kanit(
                        fontSize: 90,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              // Elderly characters illustration
              Container(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/waiwan_logo.png',
                  height: 300,
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(flex: 2),
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PhoneInputScreen()),
                    );
                  },
                  child: Text(
                    "เริ่มต้นใช้งาน",
                    style: TextStyle(
                      fontSize: fontProvider.getScaledFontSize(40),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}