import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE FILLED BUTTON--------
Widget widget_filledbutton_demo(
  String texto, {
  required VoidCallback onPressed,
}) {
  return FilledButton(onPressed: onPressed, child: Text(texto));
}

// -------- FUNCIÓN DE CREACIÓN DE FILLED TONAL BUTTON--------
Widget widget_filledtonalbutton_demo(
  String texto, {
  required VoidCallback onPressed,
}) {
  return FilledButton.tonal(onPressed: onPressed, child: Text(texto));
}

// -------- FUNCIÓN DE CREACIÓN DE BOTON DE TEXTO --------
Widget widget_textbutton_demo(String texto, {required VoidCallback onPressed}) {
  return TextButton(onPressed: onPressed, child: Text(texto));
}

// -------- FUNCIÓN DE CREACIÓN DE BOTÓN DE ICONO --------
Widget widget_iconbutton_demo(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return IconButton(icon: Icon(icono), onPressed: onPressed);
}

// -------- FUNCIÓN DE CREACIÓN DE BOTON FLOTANTE --------
Widget widget_floatingbutton_demo(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(onPressed: onPressed, child: Icon(icono));
}
