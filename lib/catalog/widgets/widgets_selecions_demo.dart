import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE CHECKBOX--------
Widget widgetCheckboxDemo(bool isChecked, void Function(bool?) onChanged) {
  return Checkbox(value: isChecked, onChanged: onChanged);
}

// -------- FUNCIÓN DE CREACIÓN DE CHECKBOX CON TEXTO--------
Widget widgetCheckboxTextoDemo(
  bool isChecked,
  String texto2,
  void Function(bool?) onChanged,
) {
  return Row(
    children: [
      Checkbox(value: isChecked, onChanged: onChanged),
      Text(texto2),
    ],
  );
}

// -------- FUNCIÓN DE CREACIÓN DE SWITCH--------
Widget widgetSwitchDemo(bool isChecked, void Function(bool) onChanged) {
  return Switch(value: isChecked, onChanged: onChanged);
}

// -------- FUNCIÓN DE CREACIÓN DE SWITCH CON TEXTO--------
Widget widgetSwitchTextoDemo(
  bool isChecked,
  String texto2,
  void Function(bool) onChanged,
) {
  return Row(
    children: [
      Switch(value: isChecked, onChanged: onChanged),
      const Text('Encender/Apagar'),
    ],
  );
}
