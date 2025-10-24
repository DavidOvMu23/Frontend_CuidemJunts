// lib/core/widgets/custom_widgets.dart
// Estructura básica de widgets reutilizables para la app.

import 'package:flutter/material.dart';

TextField app_textfield(String texto, IconData icono, bool obscureText) {
  return TextField(
    obscureText: obscureText, // Oculta el texto (para contraseñas)
    decoration: InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // Sin borde visible
      ),
    ),
  );
}
