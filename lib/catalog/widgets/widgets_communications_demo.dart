import 'package:flutter/material.dart';

// -------- WIDGETS DE COMUNICACIÓN --------
// Son funciones rápidas para no repetir el mismo widget en cada pantalla.

// La idea es tener un solo lugar donde definir la apariencia y comportamiento de los widgets.
// y así simplemente si vamos a usar un widget en una demo, llamamos a la función correspondiente.
// o si queremos cambiar alguna cosa del widget, lo hacemos aquí y se refleja en todas las demos.

// Badge sencillo para mostrar un número de notificaciones encima de un icono.
Widget widget_badge_demo(
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

// Snackbar sencillo para mostrar un mensaje en la parte inferior de la pantalla.
void widget_snackbar_demo(
  BuildContext context,
  String content,
  int durationSeconds,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      duration: Duration(seconds: durationSeconds),
    ),
  );
}
