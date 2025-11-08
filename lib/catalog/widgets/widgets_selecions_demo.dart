import 'package:flutter/material.dart';

// -------- WIDGETS DE SELECCIÓN --------
// Son funciones rápidas para no repetir el mismo widget en cada pantalla.

// La idea es tener un solo lugar donde definir la apariencia y comportamiento de los widgets.
// y así simplemente si vamos a usar un widget en una demo, llamamos a la función correspondiente.
// o si queremos cambiar alguna cosa del widget, lo hacemos aquí y se refleja en todas las demos.

// Checkbox básico (sin texto)
Widget widgetCheckboxDemo(bool isChecked, void Function(bool?) onChanged) {
  return Checkbox(value: isChecked, onChanged: onChanged);
}

// Checkbox acompañado de un texto descriptivo.
Widget widgetCheckboxTextoDemo(
  bool isChecked,
  String texto,
  void Function(bool?) onChanged,
) {
  return Row(
    children: [
      Checkbox(value: isChecked, onChanged: onChanged),
      Text(texto),
    ],
  );
}

// Switch básico (sin texto)
Widget widgetSwitchDemo(bool isChecked, void Function(bool) onChanged) {
  // Switch sin texto; ideal para colocarlo dentro de otra fila custom.
  return Switch(value: isChecked, onChanged: onChanged);
}

// Switch acompañado de un texto descriptivo.
Widget widgetSwitchTextoDemo(
  bool isChecked,
  String texto,
  void Function(bool) onChanged,
) {
  // Switch + etiqueta para explicar qué se está activando.
  return Row(
    children: [
      Switch(value: isChecked, onChanged: onChanged),
      Text(texto),
    ],
  );
}
