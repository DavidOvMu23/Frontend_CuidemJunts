import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE BOTÓN --------
Widget widget_iconbutton_demo(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return IconButton(icon: Icon(icono), onPressed: onPressed);
}
