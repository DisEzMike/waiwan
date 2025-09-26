import 'package:flutter/material.dart';
import 'package:waiwan/utils/colors.dart';
import 'package:waiwan/screens/elderlyscreen/review_screen.dart';

void main() {
  runApp(const _DebugApp());
}

class _DebugApp extends StatelessWidget {
  const _DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: myPrimaryColor,
          primary: myPrimaryColor,
          secondary: mySecondaryColor,
          surface: myBackgroundColor,
        ),
      ),
      home: const ReviewScreen(),
    );
  }
}
