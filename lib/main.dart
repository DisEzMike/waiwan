import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import 'package:waiwan/screens/start_screen.dart';
import 'package:waiwan/utils/colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: FontSizeProvider.instance,
      child: MaterialApp(
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
      ),
    );
  }
}
