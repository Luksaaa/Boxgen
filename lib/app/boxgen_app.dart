import 'package:flutter/material.dart';

import 'app_colors.dart';
import '../features/training/boxing_home_page.dart';

class BoxgenApp extends StatelessWidget {
  const BoxgenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boxgen',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Arial',
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const BoxingHomePage(),
    );
  }
}
