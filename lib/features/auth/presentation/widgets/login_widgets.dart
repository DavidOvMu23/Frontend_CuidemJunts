import 'package:flutter/material.dart';

// -------- LIST TILE PARA EL SELECTOR DE IDIOMAS --------
// muestra el texto y ejecuta onTap.
// Así el Login queda más limpio.
Widget login_listile_demo({
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(title: Text(texto), onTap: onTap);
}

// -------- ICON BUTTON PARA EL SELECTOR DE IDIOMAS --------
// muestra el icono y ejecuta onPressed.
// Así el Login queda más limpio.
Widget login_iconbutton(IconData icono, {required VoidCallback onPressed}) {
  return IconButton(icon: Icon(icono), onPressed: onPressed);
}
