import 'package:flutter/material.dart';

class AppColors {
  //ORDEN DE USO DE LOS COLORES
  // Títulos, botones principales, iconos activos
  // Botones secundarios, iconos de apoyo, bordes suaves
  // Llamadas a la acción, botones destacados
  // Fondo general de la app
  // Texto principal sobre fondo claro

  //MODO CLARO
  static const Color lightPrimary = Color(0xFF8BBFE8);
  static const Color lightSecondary = Color(0xFFA8D1EF);
  static const Color lightAccent = Color(0xFF5AA9E6);
  static const Color lightBackground = Color(0xFFFAF8F4);
  static const Color lightText = Color(0xFF3B4B5A);

  //MODO OSCURO
  static const Color darkPrimary = Color(0xFF6FB5E9);
  static const Color darkSecondary = Color(0xFF4F6F8F);
  static const Color darkAccent = Color(0xFF57A0E5);
  static const Color darkBackground = Color(0xFF1E2A35);
  static const Color darkText = Color(0xFFF2F4F6);

  //COLORES DE FEEDBACK (prueba)
  static const Color success = Colors.green;
  static const Color warning = Colors.orangeAccent;
  static const Color error = Colors.redAccent;
}
