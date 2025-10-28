import 'package:flutter/material.dart';

// No he hecho card por que en nuestro caso no tiene sentido, por que en una card vamos a almacenar
// distintos elementos depende de lo que queramos, y no tiene sentido parametrizar algo que tampoco
// sabemos ni como vamos a hacer, lo mismo pasa con el bottomsheet, y en el caso del divider no
// vale la pena por que es una mierdecilla programarlo y no hay mucho que se pueda parametrizar

// -------- FUNCIÓN DE CREACIÓN DE FILLED BUTTON--------
Widget widget_listile_demo({
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(leading: Icon(icon), title: Text(texto), onTap: onTap);
}
