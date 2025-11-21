import 'package:flutter/material.dart';

// BADGE
// Muestra un icono para las notificaciones
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

// SNACKBAR
// Muestra un mensaje en la parte inferior durante unos segundos.
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

// SNACKBAR ERROR
// Lo mismo pero con otros colores
void widget_snackbar_error_demo(
  BuildContext context,
  String content,
  int durationSeconds,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
          fontWeight: FontWeight.w600,
        ),
      ),
      duration: Duration(seconds: durationSeconds),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

// CONFIRM DIALOG
// Para mostrar un menú que te de una opción para confirmar una acción importante
Future<void> widget_showConfirmDialog_demo(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmText,
  required String cancelText,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
