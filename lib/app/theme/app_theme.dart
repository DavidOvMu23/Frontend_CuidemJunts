import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

/// Clase que define los temas de la aplicación (claro y oscuro),
/// Me lo ha hecho el chat a partir de las constantes que he definido
/// en el app palette (lo siento pepe)
class AppTheme {
  //TEMA CLARO -------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Usa el sistema de diseño Material 3
    brightness: Brightness.light, // Modo claro
    scaffoldBackgroundColor:
        AppPalette.backgroundLight, // Color de fondo principal
    primaryColor: AppPalette.primaryLight, // Color primario
    colorScheme: const ColorScheme.light(
      background: AppPalette.backgroundLight, // Fondo base
      surface: AppPalette.surfaceLight, // Superficie (tarjetas, appbars, etc.)
      primary: AppPalette.primaryLight, // Color principal
      onPrimary: AppPalette
          .onPrimaryLight, // Color del texto/iconos sobre el color primario
      secondary: AppPalette.accentLight, // Color secundario (acentos)
      error: AppPalette.errorLight, // Color de error
      onError: Colors.white, // Color del texto sobre el color de error
    ),
    cardColor: AppPalette.cardLight, // Color de las tarjetas
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.surfaceLight, // Fondo del AppBar
      foregroundColor:
          AppPalette.textPrimaryLight, // Color del texto/iconos del AppBar
      elevation: 0, // Sin sombra
      centerTitle: true, // Centra el título
      titleTextStyle: TextStyle(
        color: AppPalette.textPrimaryLight, // Color del texto del título
        fontSize: 20, // Tamaño del texto
        fontWeight: FontWeight.w600, // Grosor medio
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppPalette.textPrimaryLight, // Texto principal (títulos grandes)
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleMedium: TextStyle(
        color: AppPalette.textSecondaryLight, // Subtítulos
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyMedium: TextStyle(
        color: AppPalette.textBodyLight, // Texto del cuerpo principal
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        color: AppPalette
            .textDescriptionLight, // Descripciones o textos secundarios
        fontSize: 14,
      ),
      labelSmall: TextStyle(
        color: AppPalette.textFootnoteLight, // Notas o pies de texto
        fontSize: 12,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppPalette.primaryLight, // Color por defecto de los iconos
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.primaryLight, // Color del FAB
      foregroundColor: Colors.white, // Color del ícono del FAB
    ),
  );

  // ============================================================
  //                     🌙 TEMA OSCURO
  // ============================================================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true, // Usa Material 3
    brightness: Brightness.dark, // Modo oscuro
    scaffoldBackgroundColor:
        AppPalette.backgroundDark, // Fondo principal oscuro
    primaryColor: AppPalette.primaryDark, // Color primario oscuro
    colorScheme: const ColorScheme.dark(
      background: AppPalette.backgroundDark, // Fondo base oscuro
      surface: AppPalette.surfaceDark, // Superficies oscuras
      primary: AppPalette.primaryDark, // Color primario
      onPrimary: AppPalette.onPrimaryDark, // Texto sobre primario
      secondary: AppPalette.accentDark, // Color secundario
      error: AppPalette.errorDark, // Color de error
      onError: Colors.white, // Texto sobre color de error
    ),
    cardColor: AppPalette.cardDark, // Color de las tarjetas
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.surfaceDark, // Fondo del AppBar
      foregroundColor: AppPalette.textPrimaryDark, // Color del texto/iconos
      elevation: 0, // Sin sombra
      centerTitle: true, // Centra el título
      titleTextStyle: TextStyle(
        color: AppPalette.textPrimaryDark, // Texto del título
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppPalette.textPrimaryDark, // Títulos grandes
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleMedium: TextStyle(
        color: AppPalette.textSecondaryDark, // Subtítulos
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyMedium: TextStyle(
        color: AppPalette.textBodyDark, // Texto principal
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        color: AppPalette.textDescriptionDark, // Descripciones
        fontSize: 14,
      ),
      labelSmall: TextStyle(
        color: AppPalette.textFootnoteDark, // Notas o pies de texto
        fontSize: 12,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppPalette.primaryDark, // Color de los iconos
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.primaryDark, // Fondo del FAB
      foregroundColor: Colors.white, // Ícono del FAB
    ),
  );
}
