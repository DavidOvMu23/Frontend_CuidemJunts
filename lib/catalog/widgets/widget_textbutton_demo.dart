import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE BOTÓN --------
Widget widget_textbutton_demo(String texto, {required VoidCallback onPressed}) {
  return TextButton(onPressed: onPressed, child: Text(texto));
}
