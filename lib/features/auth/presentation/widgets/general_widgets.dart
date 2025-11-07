import 'package:flutter/material.dart';

// -------- FUNCIÓN DE CREACIÓN DE BADGE CON ICONO--------
Widget general_badge_demo(
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

// -------- FUNCIÓN DE CREACIÓN DE FILLED BUTTON--------
Widget general_filledbutton(String texto, {required VoidCallback onPressed}) {
  return FilledButton(onPressed: onPressed, child: Text(texto));
}

// -------- FUNCIÓN DE CREACIÓN DE BOTON DE TEXTO --------
Widget general_textbutton(String texto, {required VoidCallback onPressed}) {
  return TextButton(onPressed: onPressed, child: Text(texto));
}

// -------- FUNCIÓN DE CREACIÓN DE BOTÓN DE ICONO --------
Widget general_iconbutton(IconData icono, {required VoidCallback onPressed}) {
  return IconButton(icon: Icon(icono), onPressed: onPressed);
}

// -------- FUNCIÓN DE CREACIÓN DE TEXTFIELD --------
TextField general_textfield(
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
general_snackbar(BuildContext context, String content, int durationSeconds) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      duration: Duration(seconds: durationSeconds),
    ),
  );
}

// -------- FUNCIÓN DE CREACIÓN DE LISTILE --------
//la mitad de esta función es el chat gpt que me ayudó a hacer el drawer más chulo
Widget general_listile_demo({
  required BuildContext context,
  required IconData icon,
  required String texto,
  VoidCallback? onTap,
  bool selected = false,
}) {
  // Colores usados
  const iconColor = Color(0xFF42a6ee);
  //el final surfaceColor es para que el color de fondo del ListTile
  final surfaceColor = Theme.of(context).colorScheme.surface;

  return Container(
    //estilo del contenedor del ListTile
    //el decoration es para que el ListTile tenga un fondo redondeado por detras
    decoration: BoxDecoration(
      // Si está seleccionado, aplicamos el color de surface; si no, transparente
      color: selected ? surfaceColor : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
    ),

    //texto del ListTile
    child: ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        texto,
        style: TextStyle(
          color: selected ? iconColor : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    ),
  );
}
