import 'package:flutter/material.dart';

import '../features/training/boxing_home_page.dart';

class BoxgenApp extends StatelessWidget {
  const BoxgenApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF130D11);
    const surface = Color(0xFF20141B);
    const primary = Color(0xFFFF9BC0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boxgen',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: surface,
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF40202D),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const BoxingHomePage(),
    );
  }
}
