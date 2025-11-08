import 'package:flutter/material.dart';

// -------- BOTONES DE LAS DEMOS --------
// Son funciones rápidas para no repetir el mismo botón en cada pantalla.

// La idea es tener un solo lugar donde definir la apariencia y comportamiento de los botones.
// y así simplemente si vamos a usar un botón en una demo, llamamos a la función correspondiente.
// o si queremos cambiar alguna cosa del botón, lo hacemos aquí y se refleja en todas las demos.

// Botón principal con fondo sólido; ideal para acciones importantes.
Widget widget_filledbutton_demo(
  String texto, {
  required VoidCallback onPressed,
}) {
  return FilledButton(onPressed: onPressed, child: Text(texto));
}

// Variante más suave del botón principal para acciones secundarias.
Widget widget_filledtonalbutton_demo(
  String texto, {
  required VoidCallback onPressed,
}) {
  return FilledButton.tonal(onPressed: onPressed, child: Text(texto));
}

// Botón de texto simple, para acciones menos importantes.
Widget widget_textbutton_demo(String texto, {required VoidCallback onPressed}) {
  return TextButton(onPressed: onPressed, child: Text(texto));
}

// Botón con borde, para otras funciones
Widget widget_iconbutton_demo(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return IconButton(icon: Icon(icono), onPressed: onPressed);
}

// FloatingActionButton para acciones destacadas en la pantalla.
Widget widget_floatingbutton_demo(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(onPressed: onPressed, child: Icon(icono));
}
