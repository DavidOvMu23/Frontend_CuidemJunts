import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:flutter/services.dart';

// -------- WIDGETS GENERALES DE LA APP --------
// estos widgets serán los que se usarán en toda la app
// los tenemos aquí guardados y no en presentations/widgets por que nuestro
// proyecto usa la arquitectura "clean architecture" y se supone que los widgets globales
// se deben de almacenar aquí en un proyecto de flutter, se me hace raro que estén aquí y no en
// presentations/widgets pero bueno

// APPBAR
// Título centrado con botón de notificaciones
PreferredSizeWidget appMainAppBar({
  required VoidCallback onNotifications,
  int numeroNotificaciones = 0, // NUEVO PARÁMETRO
}) {
  return AppBar(
    title: const Text("CuidemJunts", style: TextStyle(fontSize: 19)),
    centerTitle: true,
    actions: [
      general_badge(
        numeroNotificaciones,
        Icons.notifications,
        onPressed: onNotifications,
      ), // USA EL PARÁMETRO
    ],
  );
}

// BADGE
// Muestra un icono para las notificaciones
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

// FILLED BUTTON
// Botón grande para acciones principales
Widget general_filledbutton(String texto, {required VoidCallback onPressed}) {
  return FilledButton(
    onPressed: onPressed,
    style: ButtonStyle(
      animationDuration: const Duration(milliseconds: 140),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.black.withValues(alpha: 0.16);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withValues(alpha: 0.10);
        }
        return null;
      }),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return 0;
        if (states.contains(WidgetState.hovered)) return 3;
        return 1;
      }),
    ),
    child: Text(texto),
  );
}

// TEXT BUTTON
// Ideal para enlaces o acciones secundarias
Widget general_textbutton(String texto, {required VoidCallback onPressed}) {
  return TextButton(onPressed: onPressed, child: Text(texto));
}

// FLOATING BUTTON
// Para acciones destacadas en la pantalla
Widget general_floatingbutton(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(onPressed: onPressed, child: Icon(icono));
}

// ICON BUTTON
// Útil cuando solo necesitamos un icono táctil (por ejemplo dar like a algo).
Widget general_iconbutton(IconData icono, {required VoidCallback onPressed}) {
  return IconButton(
    icon: Icon(icono, color: AppPalette.primaryLight),
    onPressed: onPressed,
  );
}

// TEXTFIELD
// Con icono opcional, radio y número de líneas
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
      prefixIcon: icono != null ? Icon(icono) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

//TEXTFIELD
//Lo mismo que arriba pero sin icono, pero si lo hacía con icono opcional se quedaba
//feo por que dejaba un espacio vacío antes de poner el texto y sin el obscure text

TextFormField general_textfield_NoICON(
  String texto, {
  double borderRadius = 12.0,
  int maxLines = 1,
  TextEditingController? controller,
  bool enabled = true,
  String? Function(String?)? validator,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    enabled: enabled,
    validator: validator,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
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
//Lo mismo que el primero pero con un border radius mayor para que haya diferenciia entre
//un textfield normal y este y que no fuiera solo el texto
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
      prefixIcon: Icon(icono, color: AppPalette.primaryLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

// SNACKBAR
// Muestra un mensaje en la parte inferior durante unos segundos
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

// SNACKNBAR ERROR
// Lo mismo pero con otros colores
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

// LISTILE
// Un elemento para una lista con icono, texto
Widget general_listtile({
  required BuildContext context,
  required IconData icon,
  required String texto,
  VoidCallback? onTap,
  bool selected = false,
}) {
  const iconColor =
      AppPalette.primaryLight; // Azul principal de la app para los iconos
  final surfaceColor = Theme.of(context).colorScheme.surface;
  final defaultTextColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

  return Container(
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

// LISTILE CERRAR SESIÓN
// lo mismo que arriba pero especifico para cerrar sesión por el tamaño de fuente y cosas que cambian
Widget general_listtile_logout({
  required BuildContext context,
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  const iconColor = AppPalette.primaryLight;

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

// CONFIRM DIALOG
// Para mostrar un menú que te de una opción para confirmar una acción importante, como cerrar sesión o
// eliminar un usuario, grupo, teleoperador etc...
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

// DELETE BUTTON
// Botón de eliminar
Widget general_deletebutton(
  BuildContext context,
  String texto, {
  required VoidCallback onPressed,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final backgroundColor = isDark ? AppPalette.errorDark : AppPalette.errorLight;
  final textColor = isDark
      ? AppPalette.errorFontDark
      : AppPalette.errorFontLight;

  return FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
    ),
    child: Text(texto),
  );
}
