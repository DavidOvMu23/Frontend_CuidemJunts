import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

// TEXTFIELD
// Con icono opcional, radio y número de líneas.
TextField widget_textfield_demo(
  String texto,
  bool obscureText, {
  IconData? icono,
  double borderRadius = 12.0,
  int maxLines = 1,
  TextEditingController? controller,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: texto, // Texto gris que explica qué escribir.
      prefixIcon: icono != null ? Icon(icono) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

//TEXTFIELD SIN ICONO
TextField widget_textfield_NoICON_demo(
  String texto, {
  double borderRadius = 12.0,
  int maxLines = 1,
  TextEditingController? controller,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: texto, // Texto gris que explica qué escribir.
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

//TEXTFIELD DE BÚSQUEDA
TextField widget_busqueda_textfield_demo(
  String texto, {
  IconData? icono,
  double borderRadius = 50.0,
  TextEditingController? controller,
  ValueChanged<String>? onChanged,
  BuildContext? context, // Contexto opcional
}) {
  final iconColor = context != null
      ? Theme.of(context).colorScheme.primary
      : AppPalette.primaryLight;

  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: texto, // Texto gris que explica qué escribir.
      prefixIcon: Icon(icono, color: iconColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}
