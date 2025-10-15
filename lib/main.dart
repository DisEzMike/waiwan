import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import 'package:waiwan/providers/chat_provider.dart';
import 'package:waiwan/screens/start_screen.dart';
import 'package:waiwan/screens/profile_upload_screen.dart';
import 'package:waiwan/screens/main_screen.dart';
import 'package:waiwan/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  await initializeDateFormatting('th', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: FontSizeProvider.instance),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Use Consumer so MaterialApp rebuilds when font size changes
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return MaterialApp(
          title: 'Waiwan',
          // Ensure textScaleFactor follows the app-wide font scale
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaleFactor: fontProvider.fontSizeScale),
              child: child ?? const SizedBox.shrink(),
            );
          },
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
              Theme.of(context).textTheme.apply(
                bodyColor: myTextColor,
                displayColor: myTextColor,
              ),
            ),
            buttonTheme: ButtonThemeData(
              buttonColor: myTextButtonColor,
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          home: const StartScreen(),
          routes: {
            '/profile-upload': (context) => const ProfileUploadScreen(),
            '/main': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              int idx = 0;
              if (args is Map && args['initialIndex'] is int)
                idx = args['initialIndex'] as int;
              return MyMainPage(initialIndex: idx);
            },
          },
        );
      },
    );
  }
}
