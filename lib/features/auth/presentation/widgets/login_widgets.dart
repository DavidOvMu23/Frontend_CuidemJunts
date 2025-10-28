import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE FILLED BUTTON--------
Widget login_filledbutton(String texto, {required VoidCallback onPressed}) {
  return FilledButton(onPressed: onPressed, child: Text(texto));
}

// -------- FUNCIÓN DE CREACIÓN DE BOTON DE TEXTO --------
Widget login_textbutton(String texto, {required VoidCallback onPressed}) {
  return TextButton(onPressed: onPressed, child: Text(texto));
}

// -------- FUNCIÓN DE CREACIÓN DE BOTÓN DE ICONO --------
Widget login_iconbutton(IconData icono, {required VoidCallback onPressed}) {
  return IconButton(icon: Icon(icono), onPressed: onPressed);
}

// -------- FUNCIÓN DE CREACIÓN DE TEXTFIELD --------
TextField login_textfield(
  // Parámetros de entrada
  String texto,
  bool obscureText, {
  // Parámetros opcionales con valores por defecto
  IconData? icono,
  double borderRadius = 12.0,
  int maxLines = 1,
}) {
  // -------- CONSTRUCCIÓN DEL TEXTFIELD --------
  return TextField(
    obscureText: obscureText,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

// -------- FUNCIÓN DE CREACIÓN DEL SNACKBAR --------
login_snackbar(BuildContext context, String content, int durationSeconds) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      duration: Duration(seconds: durationSeconds),
    ),
  );
}

// -------- FUNCIÓN DE CREACIÓN DE FILLED BUTTON--------
Widget login_listile_demo({
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(title: Text(texto), onTap: onTap);
}
