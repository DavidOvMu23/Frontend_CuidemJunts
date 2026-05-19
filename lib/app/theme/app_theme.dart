// Paquete principal de Flutter
import 'package:flutter/material.dart';
// Paleta de colores de la app (ver app_palette.dart)
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

// -------- TEMA GLOBAL DE LA APP --------
// Aquí creamos los ThemeData claro/oscuro usando la paleta definida en app_palette.dart.
// Un ThemeData es como una "hoja de estilos" global: en lugar de repetir colores y tamaños
// en cada widget, los definimos una vez aquí y Flutter los aplica en toda la app.
//
// Están definidos los estilos de: AppBar, textos, campos de texto, botones, tarjetas y drawer.
//
// Nota: este archivo fue generado con ayuda de ChatGPT a partir de la paleta de colores.

class AppTheme {
  // -------- TEMA CLARO --------
  // Este objeto describe cómo debe verse la app cuando el usuario tiene el tema claro activado
  static final ThemeData lightTheme = ThemeData(
    // Usamos Material Design 3 (la versión más moderna de las guías visuales de Google)
    useMaterial3: true,
    brightness: Brightness.light,

    // Color de fondo de todas las pantallas en modo claro
    scaffoldBackgroundColor: AppPalette.backgroundLight,

    // Esquema de colores principal: define qué color usar para botones, fondos, errores, etc.
    colorScheme: const ColorScheme.light(
      primary: AppPalette.primaryLight,           // Color de botones y elementos principales
      secondary: AppPalette.accentLight,           // Color de elementos secundarios
      surface: AppPalette.surfaceLight,            // Color de paneles y diálogos
      background: AppPalette.backgroundLight,      // Color de fondo general
      error: AppPalette.errorFontDark,             // Color para mensajes de error
      onPrimary: AppPalette.textOnPrimaryLight,    // Texto encima de botones principales
      onSurface: AppPalette.textOnSurfaceLight,    // Texto encima de paneles
      onBackground: AppPalette.textPrimaryLight,   // Texto encima del fondo
    ),

    // Estilo de la barra superior (AppBar) que aparece en la parte de arriba de cada pantalla
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.backgroundLight, // Mismo color que el fondo (sin contraste brusco)
      foregroundColor: AppPalette.menuLight,        // Color de los iconos y título
      elevation: 0,                                 // Sin sombra debajo del AppBar
      titleTextStyle: TextStyle(
        color: AppPalette.menuLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      // Color de los iconos del AppBar (hamburguesa, flecha atrás, etc.)
      iconTheme: IconThemeData(color: AppPalette.menuLight),
    ),

    // Estilos globales de texto, organizados por tamaño/importancia
    textTheme: const TextTheme(
      // Títulos muy grandes (ej: encabezado de una sección)
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppPalette.textPrimaryLight,
      ),
      // Títulos de página o diálogo
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppPalette.textPrimaryLight,
      ),
      // Texto de cuerpo grande (párrafos principales)
      bodyLarge: TextStyle(fontSize: 16, color: AppPalette.textPrimaryLight),
      // Texto de cuerpo mediano (la mayoría de textos de la app)
      bodyMedium: TextStyle(fontSize: 14, color: AppPalette.textSecondaryLight),
      // Texto pequeño (etiquetas, metadatos secundarios)
      bodySmall: TextStyle(fontSize: 12, color: AppPalette.textMutedLight),
    ),

    // Estilo global de todos los campos de texto (inputs) de la app
    inputDecorationTheme: InputDecorationTheme(
      filled: true,                              // El campo tiene fondo de color
      fillColor: AppPalette.cardLight,            // Color de fondo del campo
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // Borde normal (cuando el campo no está seleccionado)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.accentLight, width: 1),
      ),
      // Borde cuando el campo está seleccionado (más grueso y color primario para guiar al usuario)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPalette.primaryLight, width: 2),
      ),
      // Color del texto de ayuda dentro del campo cuando está vacío
      hintStyle: const TextStyle(color: AppPalette.textMutedLight),
    ),

    // Estilo global de los botones rellenos (ElevatedButton / FilledButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primaryLight,      // Fondo azul
        foregroundColor: AppPalette.textOnPrimaryLight, // Texto blanco
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    // Color de las tarjetas (Card widgets)
    cardColor: AppPalette.cardLight,
    cardTheme: const CardThemeData(
      color: AppPalette.cardLight,             // Color propio distinto del surface
      surfaceTintColor: Colors.transparent,    // Evita que Material3 mezcle colores automáticamente
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Estilo del menú lateral (Drawer) que se abre desde la izquierda
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPalette.backgroundLight,
      surfaceTintColor: Colors.transparent,    // Sin mezcla automática de Material3
    ),

    // Color de las líneas separadoras entre elementos de listas
    dividerColor: AppPalette.accentLight.withOpacity(0.3),
    // Color por defecto de todos los iconos de la app
    iconTheme: const IconThemeData(color: AppPalette.menuLight),
  );

  // -------- TEMA OSCURO --------
  // Igual que el claro pero con los colores oscuros de la paleta
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Fondo general de todas las pantallas en modo oscuro
    scaffoldBackgroundColor: AppPalette.backgroundDark,

    // Esquema de colores para modo oscuro
    colorScheme: const ColorScheme.dark(
      primary: AppPalette.primaryDark,
      secondary: AppPalette.accentDark,
      surface: AppPalette.surfaceDark,           // Paneles y diálogos oscuros
      background: AppPalette.backgroundDark,
      error: AppPalette.errorFontDark,
      onPrimary: AppPalette.textOnPrimaryDark,
      onSurface: AppPalette.textOnSurfaceDark,
      onBackground: AppPalette.textPrimaryDark,
    ),

    // AppBar en modo oscuro
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

    // Textos en modo oscuro (mismos tamaños, colores más claros para contrastar con el fondo oscuro)
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

    // Campos de texto en modo oscuro
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

    // Botones en modo oscuro
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primaryDark,
        foregroundColor: AppPalette.textOnPrimaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    // Tarjetas en modo oscuro
    cardColor: AppPalette.cardDark,
    cardTheme: const CardThemeData(
      color: AppPalette.cardDark,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Drawer (menú lateral) en modo oscuro
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPalette.backgroundDark,
      surfaceTintColor: Colors.transparent,
    ),

    // Separadores y iconos en modo oscuro
    dividerColor: AppPalette.accentDark.withOpacity(0.3),
    iconTheme: const IconThemeData(color: AppPalette.menuDark),
  );
}
