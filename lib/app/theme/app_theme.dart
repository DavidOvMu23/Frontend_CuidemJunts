import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

/// Clase que define los temas de la aplicación (claro y oscuro),
/// Me lo ha hecho el chat a partir de las constantes que he definido
/// en el app palette (lo siento pepe)
class AppTheme {
  // MODO CLARO -------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPalette.backgroundLight,
    primaryColor: AppPalette.primaryLight,
    colorScheme: const ColorScheme.light(
      surface: AppPalette.surfaceLight,
      primary: AppPalette.primaryLight,
      onPrimary: AppPalette.onPrimaryLight,
      secondary: AppPalette.accentLight,
      error: AppPalette.errorLight,
      onError: AppPalette.errorFontLight,
    ),
    cardColor: AppPalette.cardLight,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.surfaceLight,
      foregroundColor: AppPalette.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppPalette.textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Textos
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppPalette.textPrimaryLight,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleMedium: TextStyle(
        color: AppPalette.textSecondaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyMedium: TextStyle(color: AppPalette.textBodyLight, fontSize: 16),
      bodySmall: TextStyle(
        color: AppPalette.textDescriptionLight,
        fontSize: 14,
      ),
      labelSmall: TextStyle(color: AppPalette.textFootnoteLight, fontSize: 12),
    ),

    // Botones principales
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primaryLight,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        elevation: 1.5,
      ),
    ),

    // Botones tonales
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppPalette.accentLight,
        foregroundColor: AppPalette.textPrimaryLight,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),

    // Iconos
    iconTheme: const IconThemeData(color: AppPalette.primaryLight),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.primaryLight,
      foregroundColor: Colors.white,
    ),

    // Estados personalizados
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppPalette.surfaceLight,
      contentTextStyle: TextStyle(color: AppPalette.textPrimaryLight),
    ),
  );

  // MODO OSCURO -----------------------------------------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppPalette.backgroundDark,
    primaryColor: AppPalette.primaryDark,
    colorScheme: const ColorScheme.dark(
      surface: AppPalette.surfaceDark,
      primary: AppPalette.primaryDark,
      onPrimary: AppPalette.onPrimaryDark,
      secondary: AppPalette.accentDark,
      error: AppPalette.errorDark,
      onError: AppPalette.errorFontDark,
    ),
    cardColor: AppPalette.cardDark,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.surfaceDark,
      foregroundColor: AppPalette.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppPalette.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Textos
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppPalette.textPrimaryDark,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleMedium: TextStyle(
        color: AppPalette.textSecondaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyMedium: TextStyle(color: AppPalette.textBodyDark, fontSize: 16),
      bodySmall: TextStyle(color: AppPalette.textDescriptionDark, fontSize: 14),
      labelSmall: TextStyle(color: AppPalette.textFootnoteDark, fontSize: 12),
    ),

    // Botones principales
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primaryDark,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),

    // Botones tonales
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppPalette.accentDark,
        foregroundColor: AppPalette.textPrimaryDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),

    // Iconos
    iconTheme: const IconThemeData(color: AppPalette.primaryDark),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.primaryDark,
      foregroundColor: Colors.white,
    ),
  );
}
