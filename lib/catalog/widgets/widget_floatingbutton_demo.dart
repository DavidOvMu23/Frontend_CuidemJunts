import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE BOTÓN --------
Widget widget_floatingbutton_demo(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(onPressed: onPressed, child: Icon(icono));
}
