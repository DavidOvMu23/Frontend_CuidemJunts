import 'package:flutter/material.dart';

// -------- WIDGETS PERSONALIZADOS PARA LA PÁGINA DE INICIO --------
// Estos widgets son específicos para la pantalla de inicio

// listile para caerar sesión
Widget home_listtile_logout({
  required BuildContext context,
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  const iconColor = Color(0xFF42a6ee);

  return ListTile(
    horizontalTitleGap: 2,
    leading: Icon(icon, color: iconColor, size: 16),
    title: Text(
      texto,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
    ),
    onTap: onTap,
  );
}
