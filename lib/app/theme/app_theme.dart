import 'package:flutter/material.dart';
import 'app_palette.dart';

/// Configuración global de temas para CuidemJunts
/// Usa la paleta base (AppPalette) y define estilos de texto, inputs, botones, etc.
class AppTheme {
  /// ==================== TEMA CLARO ====================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPalette.backgroundLight,
    primaryColor: AppPalette.primaryLight,
    colorScheme: const ColorScheme.light(
      primary: AppPalette.primaryLight,
      secondary: AppPalette.accentLight,
      surface: AppPalette.surfaceLight,
      background: AppPalette.backgroundLight,
      error: AppPalette.errorLight,
      onPrimary: AppPalette.textOnPrimaryLight,
      onSurface: AppPalette.textOnSurfaceLight,
      onBackground: AppPalette.textPrimaryLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.backgroundLight,
      foregroundColor: AppPalette.menuLight,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppPalette.menuLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppPalette.menuLight),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppPalette.textPrimaryLight,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppPalette.textPrimaryLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPalette.textPrimaryLight,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppPalette.textSecondaryLight),
      bodySmall: TextStyle(fontSize: 12, color: AppPalette.textMutedLight),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.cardLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.accentLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.primaryLight, width: 2),
      ),
      hintStyle: const TextStyle(color: AppPalette.textMutedLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primaryLight,
        foregroundColor: AppPalette.textOnPrimaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    cardColor: AppPalette.cardLight,
    dividerColor: AppPalette.accentLight.withOpacity(0.3),
    iconTheme: const IconThemeData(color: AppPalette.menuLight),
  );

  /// ==================== TEMA OSCURO ====================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPalette.backgroundDark,
    primaryColor: AppPalette.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppPalette.primaryDark,
      secondary: AppPalette.accentDark,
      surface: AppPalette.surfaceDark,
      background: AppPalette.backgroundDark,
      error: AppPalette.errorDark,
      onPrimary: AppPalette.textOnPrimaryDark,
      onSurface: AppPalette.textOnSurfaceDark,
      onBackground: AppPalette.textPrimaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.backgroundDark,
      foregroundColor: AppPalette.menuDark,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppPalette.menuDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppPalette.menuDark),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppPalette.textPrimaryDark,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppPalette.textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppPalette.textPrimaryDark,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppPalette.textSecondaryDark),
      bodySmall: TextStyle(fontSize: 12, color: AppPalette.textMutedDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.accentDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.primaryDark, width: 2),
      ),
      hintStyle: const TextStyle(color: AppPalette.textMutedDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primaryDark,
        foregroundColor: AppPalette.textOnPrimaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    cardColor: AppPalette.cardDark,
    dividerColor: AppPalette.accentDark.withOpacity(0.3),
    iconTheme: const IconThemeData(color: AppPalette.menuDark),
  );
}
