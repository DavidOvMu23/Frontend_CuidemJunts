import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE BOTÓN --------
widget_snackbar_demo(
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
