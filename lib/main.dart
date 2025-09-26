import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:waiwan/screens/main_screen.dart';
import 'package:waiwan/screens/elderlyscreen/start_screen.dart';
import 'package:waiwan/screens/elderlyscreen/phone_input_screen.dart';
import 'package:waiwan/screens/elderlyscreen/idcard_scan_screen.dart';
import 'package:waiwan/screens/elderlyscreen/face_scan.dart';
import 'package:waiwan/screens/elderlyscreen/otp_screen.dart';
import 'package:waiwan/screens/elderlyscreen/personal_info_screen.dart';
import 'package:waiwan/screens/elderlyscreen/review_screen.dart';
import 'package:waiwan/utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waiwan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6EB715),
          primary: myPrimaryColor,
          secondary: mySecondaryColor,
          surface: myBackgroundColor,
        ),
        primaryTextTheme: TextTheme(
          bodyLarge: TextStyle(color: myTextColor),
          bodyMedium: TextStyle(color: myTextColor),
          bodySmall: TextStyle(color: myTextColor),
        ),
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(
            context,
          ).textTheme.apply(bodyColor: myTextColor, displayColor: myTextColor),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: myTextButtonColor,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: const StartScreen(),

      routes: {
        '/review': (context) => const ReviewScreen(),
        '/phone': (context) => PhoneInputScreen(),
        '/otp': (context) => const OtpScreen(),
        '/idcard': (context) => const IdCardScanScreen(),
        '/face': (context) => const FaceScanScreen(),
        '/personal_info': (context) => const PersonalInfoScreen(),
      },
    );
  }
}
