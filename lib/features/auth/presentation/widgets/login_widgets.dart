import 'package:flutter/material.dart';

// -------- LIST TILE PARA EL SELECTOR DE IDIOMAS --------
// Funcióncita ultra simple: muestra el texto y ejecuta onTap.
// Así el Login queda más limpio.
Widget login_listile_demo({
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(title: Text(texto), onTap: onTap);
}
