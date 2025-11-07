import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

//El chatgpt me ha hecho un tema completo basado en la paleta de colores que definímos
//en app_palette.dart

class AppTheme {
  // -------- TEMA CLARO --------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Fondo general de la app
    scaffoldBackgroundColor: AppPalette.backgroundLight,

    // Colores principales y del esquema
    colorScheme: const ColorScheme.light(
      primary: AppPalette.primaryLight,
      secondary: AppPalette.accentLight,
      surface: AppPalette.surfaceLight, // <- Surface (Material)
      background: AppPalette.backgroundLight,
      error: AppPalette.errorFontLight,
      onPrimary: AppPalette.textOnPrimaryLight,
      onSurface: AppPalette.textOnSurfaceLight,
      onBackground: AppPalette.textPrimaryLight,
    ),

    // AppBar (parte superior)
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

    // Tipografía general
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
      bodyLarge: TextStyle(fontSize: 16, color: AppPalette.textPrimaryLight),
      bodyMedium: TextStyle(fontSize: 14, color: AppPalette.textSecondaryLight),
      bodySmall: TextStyle(fontSize: 12, color: AppPalette.textMutedLight),
    ),

    // Estilo global de los campos de texto
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.cardLight, // <- los TextField usan este color
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

    // Botones elevados (FilledButton, ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primaryLight,
        foregroundColor: AppPalette.textOnPrimaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    // Cards
    cardColor: AppPalette.cardLight,
    cardTheme: const CardThemeData(
      color: AppPalette.cardLight, // <- color propio distinto del surface
      surfaceTintColor: Colors.transparent, // <- evita mezcla con Material3
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPalette.backgroundLight,
      surfaceTintColor: Colors.transparent,
    ),

    dividerColor: AppPalette.accentLight.withOpacity(0.3),
    iconTheme: const IconThemeData(color: AppPalette.menuLight),
  );

  // -------- TEMA OSCURO --------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppPalette.backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: AppPalette.primaryDark,
      secondary: AppPalette.accentDark,
      surface: AppPalette.surfaceDark, // <- Surface (Material)
      background: AppPalette.backgroundDark,
      error: AppPalette.errorFontDark,
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
      bodyLarge: TextStyle(fontSize: 16, color: AppPalette.textPrimaryDark),
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
    cardTheme: const CardThemeData(
      color: AppPalette.cardDark,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPalette.backgroundDark,
      surfaceTintColor: Colors.transparent,
    ),

    dividerColor: AppPalette.accentDark.withOpacity(0.3),
    iconTheme: const IconThemeData(color: AppPalette.menuDark),
  );
}
