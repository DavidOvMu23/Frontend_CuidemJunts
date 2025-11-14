import 'package:flutter/material.dart';

// -------- WIDGETS QUE REPITO POR TODA LA APP --------
// Son las piezas básicas que uso una y otra vez. Prefiero tenerlas aquí y listo.

// -------- APP BAR ESTÁNDAR DE LA APP --------
// Título centrado + botón de notificaciones reutilizable.
PreferredSizeWidget appMainAppBar({required VoidCallback onNotifications}) {
  return AppBar(
    title: const Text("CuidemJunts", style: TextStyle(fontSize: 19)),
    centerTitle: true,
    actions: [
      general_badge(10, Icons.notifications, onPressed: onNotifications),
    ],
  );
}

// -------- BADGE CON ICONO --------
// Muestra un icono con un numerito encima (ideal para notificaciones).
Widget general_badge(
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

// -------- BOTÓN RELLENO (FilledButton) --------
// Botón grande para acciones principales, solo necesita texto y qué hacer al pulsar.
Widget general_filledbutton(String texto, {required VoidCallback onPressed}) {
  return FilledButton(onPressed: onPressed, child: Text(texto));
}

// -------- BOTÓN DE TEXTO --------
// Ideal para enlaces o acciones secundarias sin fondo sólido.
Widget general_textbutton(String texto, {required VoidCallback onPressed}) {
  return TextButton(onPressed: onPressed, child: Text(texto));
}

// FloatingActionButton para acciones destacadas en la pantalla.
Widget general_floatingbutton(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(onPressed: onPressed, child: Icon(icono));
}

// -------- BOTÓN DE ICONO --------
// Útil cuando solo necesitamos un icono táctil (por ejemplo, editar o eliminar).
Widget general_iconbutton(IconData icono, {required VoidCallback onPressed}) {
  return IconButton(
    icon: Icon(icono, color: const Color(0xFF42a6ee)),
    onPressed: onPressed,
  );
}

// -------- CAMPO DE TEXTO --------
// Crea un TextField personalizable con icono opcional, radio y número de líneas.
TextField general_textfield(
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
      prefixIcon: Icon(icono),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

TextField general_busqueda_textfield(
  String texto, {
  IconData? icono,
  double borderRadius = 50.0,
  TextEditingController? controller,
  ValueChanged<String>? onChanged,
}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: texto, // Texto gris que explica qué escribir.
      prefixIcon: Icon(icono, color: Color(0xFF42a6ee)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

// -------- SNACKBAR GENERAL --------
// Muestra un mensajito en la parte inferior durante unos segundos.
void general_snackbar(
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

void general_snackbar_error(
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

// -------- ELEMENTO DE LISTA PARA EL DRAWER --------
// Es el botón del menú lateral con icono, texto y estado "seleccionado".
Widget general_listtile({
  required BuildContext context,
  required IconData icon,
  required String texto,
  VoidCallback? onTap,
  bool selected = false,
}) {
  const iconColor = Color(0xFF42a6ee); // Azul corporativo para los iconos.
  final surfaceColor = Theme.of(context).colorScheme.surface;
  final defaultTextColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

  return Container(
    // Fondo redondeado para que parezca una pastilla.
    decoration: BoxDecoration(
      color: selected ? surfaceColor : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
    ),
    child: ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        texto,
        style: TextStyle(
          color: selected ? iconColor : defaultTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    ),
  );
}

// -------- ELEMENTO DE LISTA PARA CERRAR SESIÓN --------
Widget general_listtile_logout({
  required BuildContext context,
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  const iconColor = Color(0xFF42a6ee);

  return ListTile(
    horizontalTitleGap: 2,
    leading: Icon(icon, color: iconColor, size: 16),
    title: Text(
      texto,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
    ),
    onTap: onTap,
  );
}

// -------- DIÁLOGO DE CONFIRMACIÓN GENÉRICO --------
Future<void> showConfirmDialog(
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
