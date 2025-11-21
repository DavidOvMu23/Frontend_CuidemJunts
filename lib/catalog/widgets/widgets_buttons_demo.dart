import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

// FILLED BUTTON
// Botón grande para acciones principales
Widget widget_filledbutton_demo(
  String texto, {
  required VoidCallback onPressed,
}) {
  return FilledButton(onPressed: onPressed, child: Text(texto));
}

// TEXT BUTTON
// Ideal para enlaces o acciones secundarias
Widget widget_textbutton_demo(String texto, {required VoidCallback onPressed}) {
  return TextButton(onPressed: onPressed, child: Text(texto));
}

// FLOATING BUTTON
// Para acciones destacadas en la pantalla
Widget widget_floatingbutton_demo(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(onPressed: onPressed, child: Icon(icono));
}

// ICON BUTTON
// Útil cuando solo necesitamos un icono táctil (por ejemplo dar like a algo).
Widget widget_iconbutton_demo(
  IconData icono, {
  required VoidCallback onPressed,
  BuildContext? context, // Contexto opcional para acceder al tema
}) {
  // Si tenemos contexto, usamos el color primario del tema.
  // Si no, usamos un fallback (aunque lo ideal es pasar siempre el contexto).
  final color = context != null
      ? Theme.of(context).colorScheme.primary
      : AppPalette.primaryLight;

  return IconButton(
    icon: Icon(icono, color: color),
    onPressed: onPressed,
  );
}
