import 'package:flutter/material.dart';

// -------- TEXTFIELDS --------

// Son funciones rápidas para no repetir el mismo widget en cada pantalla.

// La idea es tener un solo lugar donde definir la apariencia y comportamiento de los widgets.
// y así simplemente si vamos a usar un widget en una demo, llamamos a la función correspondiente.
// o si queremos cambiar alguna cosa del widget, lo hacemos aquí y se refleja en todas las demos.

// TextField
TextField widget_textfield_demo(
  String texto,
  bool obscureText, {
  IconData? icono,
  double borderRadius = 12.0,
  int maxLines = 1,
}) {
  return TextField(
    obscureText: obscureText, // true para contraseñas.
    maxLines: maxLines, // >1 convierte el campo en un área de texto.
    decoration: InputDecoration(
      hintText: texto, // Texto gris que indica qué escribir.
      prefixIcon: icono != null ? Icon(icono) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}
