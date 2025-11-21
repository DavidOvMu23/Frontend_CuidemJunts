import 'package:flutter/material.dart';

// LISTILE
// Un elemento para una lista con icono, texto
Widget widget_listtile_demo({
  required BuildContext context,
  required IconData icon,
  required String texto,
  VoidCallback? onTap,
  bool selected = false,
}) {
  final iconColor = Theme.of(
    context,
  ).colorScheme.primary; // Color primario del tema
  final surfaceColor = Theme.of(context).colorScheme.surface;
  final defaultTextColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

  return Container(
    // Fondo redondeado para que parezca una pastilla.
    decoration: BoxDecoration(
      color: selected ? surfaceColor : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
    ),
    child: ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        texto,
        style: TextStyle(
          color: selected ? iconColor : defaultTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    ),
  );
}

// LISTILE CERRAR SESIÓN
Widget widget_listtile_logout_demo({
  required BuildContext context,
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  final iconColor = Theme.of(context).colorScheme.primary;

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
