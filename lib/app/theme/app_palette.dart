// Paquete de Flutter necesario para usar el tipo Color
import 'package:flutter/material.dart';

// Paleta de colores centralizada de la app.
// Tener todos los colores aquí evita usar valores hexadecimales sueltos por el código:
// si queremos cambiar un color, solo lo cambiamos en un único sitio.
// Los colores se organizan por tema (claro / oscuro) y por función (fondo, tarjeta, texto…).

class AppPalette {
  // -------- TEMA CLARO --------

  // Color de fondo de toda la pantalla en modo claro (azul muy pálido)
  static const Color backgroundLight = Color(0xFFDEEEFA);
  // Color de paneles y superficies elevadas (un poco más oscuro que el fondo)
  static const Color surfaceLight = Color(0xFFC4E0F5);
  // Color de tarjetas e inputs (el más oscuro de los tres fondos en claro)
  static const Color cardLight = Color(0xFFAAD2F0);
  // Color de botones principales y elementos destacados (azul medio)
  static const Color primaryLight = Color(0xFF2F91D9);
  // Color de acciones secundarias y bordes (azul más suave que el primario)
  static const Color accentLight = Color(0xFF7CB9E0);
  // Color de iconos y texto del AppBar en modo claro (azul muy oscuro, casi negro)
  static const Color menuLight = Color(0xFF0F2A47);

  // Estados de retroalimentación visual (éxito, aviso y error) — para banners o textos informativos.
  // Cada estado tiene un color de fondo y otro para el texto encima de ese fondo.
  static const Color successLight = Color(0xFFDCFCE7);      // Fondo verde claro
  static const Color successFontLight = Color(0xFF166534);  // Texto verde oscuro
  static const Color warningLight = Color(0xFFFEF9C3);      // Fondo amarillo claro
  static const Color warningFontLight = Color(0xFF895314);  // Texto naranja oscuro
  static const Color errorLight = Color(0xFFFEE2e2);        // Fondo rojo claro
  static const Color errorFontLight = Color(0xFFA83B3D);    // Texto rojo oscuro

  // Colores de texto en modo claro, ordenados por jerarquía visual
  static const Color textPrimaryLight = Color(0xFF0F2A47);   // Texto principal (títulos)
  static const Color textSecondaryLight = Color(0xFF3A4F66); // Texto secundario (subtítulos)
  static const Color textMutedLight = Color(0xFF6B8299);     // Texto apagado (placeholders, hints)
  static const Color textOnPrimaryLight = Colors.white;      // Texto blanco sobre botones azules
  static const Color textOnSurfaceLight = Color(0xFF0F2A47); // Texto sobre paneles claros

  // -------- TEMA OSCURO --------

  // Color de fondo general en modo oscuro (azul muy muy oscuro)
  static const Color backgroundDark = Color(0xFF0a1524);
  // Color de paneles elevados en modo oscuro (un poco más claro que el fondo)
  static const Color surfaceDark = Color(0xFF192b3e);
  // Color de tarjetas e inputs en modo oscuro
  static const Color cardDark = Color(0xFF243f5b);
  // Color de botones principales en modo oscuro (azul más brillante para destacar sobre el fondo oscuro)
  static const Color primaryDark = Color(0xFF42a6ee);
  // Color de acciones secundarias en modo oscuro
  static const Color accentDark = Color(0xFF8fc7e8);
  // Color de iconos y texto del AppBar en modo oscuro (blanco puro para contrastar)
  static const Color menuDark = Color(0xFFFFFFFF);

  // Estados de retroalimentación en modo oscuro (colores más apagados para no cansar la vista)
  static const Color successDark = Color(0xFF064424);        // Fondo verde oscuro
  static const Color successFontDark = Color(0xFF7FD5A1);   // Texto verde claro
  static const Color warningDark = Color(0xFF403B03);        // Fondo amarillo oscuro
  static const Color warningFontDark = Color(0xFFE4AD6C);   // Texto naranja claro
  static const Color errorDark = Color(0xFF430505);          // Fondo rojo oscuro
  static const Color errorFontDark = Color(0xFFCD5B5B);     // Texto rojo claro

  // Colores de texto en modo oscuro
  static const Color textPrimaryDark = Color(0xFFb7e0ff);    // Texto principal (azul muy claro)
  static const Color textSecondaryDark = Color(0xFF7a8ea1);  // Texto secundario
  static const Color textMutedDark = Color(0xFF5C6F83);      // Texto apagado (placeholders)
  static const Color textOnPrimaryDark = Colors.white;       // Texto blanco sobre botones
  static const Color textOnSurfaceDark = Color(0xFFE3F2FD);  // Texto sobre paneles oscuros
}
