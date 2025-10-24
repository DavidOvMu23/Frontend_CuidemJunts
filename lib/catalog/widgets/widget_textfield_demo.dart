import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names

// -------- FUNCIÓN DE CREACIÓN DE TEXTFIELD --------
TextField widget_textfield_demo(
  // Parámetros de entrada
  String texto,
  bool obscureText, {
  // Parámetros opcionales con valores por defecto
  IconData? icono,
  double borderRadius = 12.0,
  int maxLines = 1,
}) {
  // -------- CONSTRUCCIÓN DEL TEXTFIELD --------
  return TextField(
    obscureText: obscureText,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
