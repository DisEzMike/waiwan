import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waiwan/screens/main_screen.dart';
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
          seedColor: myPrimaryColor,
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
      home: const MyMainPage(),
    );
  }
}
