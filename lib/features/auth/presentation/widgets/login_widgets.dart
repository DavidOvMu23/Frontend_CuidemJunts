import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE FILLED BUTTON--------
//es difererente al general por que este no interesa con icono
Widget login_listile_demo({
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(title: Text(texto), onTap: onTap);
}
