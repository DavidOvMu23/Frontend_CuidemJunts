import 'package:flutter/material.dart';
import 'app_palette.dart';

class AppTheme {
  //TEMA CLARO
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      background: AppColors.lightBackground,
      surface: AppColors.lightSecondary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.lightText,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(color: AppColors.lightText, fontSize: 16),
      bodySmall: TextStyle(color: AppColors.lightText, fontSize: 13),
    ),
    useMaterial3: true,
  );

  // TEMA OSCURO
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      background: AppColors.darkBackground,
      surface: AppColors.darkSecondary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.darkText,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.darkText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(color: AppColors.darkText, fontSize: 16),
      bodySmall: TextStyle(color: AppColors.darkText, fontSize: 13),
    ),
    useMaterial3: true,
  );
}
