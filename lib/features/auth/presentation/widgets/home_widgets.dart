import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DEL BADGE --------
Widget home_badge_demo(
  int numeroNotificaciones,
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return Badge(
    label: Text(numeroNotificaciones.toString()),
    alignment: Alignment.topLeft,
    child: IconButton(icon: Icon(icono), onPressed: onPressed),
  );
}

// -------- FUNCIÓN DE CREACIÓN DE LISTILE--------
Widget home_listile_demo({
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(leading: Icon(icon), title: Text(texto), onTap: onTap);
}
