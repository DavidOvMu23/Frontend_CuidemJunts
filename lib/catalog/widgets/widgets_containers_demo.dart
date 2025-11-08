import 'package:flutter/material.dart';

// -------- LIST TILE PARA EL CATÁLOGO --------
// Es el mismo patrón visual que usamos en el Drawer: icono + texto + acción.
Widget widget_listile_demo({
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(texto),
    onTap: onTap,
  );
}
