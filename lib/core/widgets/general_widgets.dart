// Dio: librería para hacer peticiones HTTP al servidor (backend)
import 'package:dio/dio.dart';
// Paquete principal de Flutter
import 'package:flutter/material.dart';
// Para restringir el tipo de teclado y los caracteres permitidos en campos de texto
import 'package:flutter/services.dart';
// Paleta de colores de la app
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
// Textos traducidos de la app (español, catalán, inglés)
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// -------- WIDGETS REUTILIZABLES --------
// Este archivo reúne funciones y widgets que se usan en muchas pantallas de la app.
// En lugar de copiar el mismo código en cada pantalla, lo centralizamos aquí.

// ── Utilidad de errores ───────────────────────────────────────────────────────

// Convierte cualquier error de red en un texto legible para el usuario.
// El servidor (NestJS) puede devolver el error como texto, lista o mapa;
// esta función se encarga de extraer siempre un mensaje comprensible.
String extractErrorMessage(dynamic e) {
  // Comprobamos si el error viene de una petición HTTP (DioException)
  if (e is DioException) {
    try {
      // Intentamos obtener los datos que devolvió el servidor
      final data = e.response?.data;
      // Si el servidor devolvió un objeto con campo 'message'...
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        // A veces NestJS devuelve varios errores como lista; los unimos con coma
        if (msg is List) return msg.join(', ');
        return msg.toString();
      }
      // Si devolvió otra cosa, la convertimos a texto
      if (data != null) return data.toString();
    } catch (_) {
      // Si algo falla al leer la respuesta, continuamos al mensaje genérico
    }
    // Si no hay datos de respuesta, usamos el mensaje del propio error de red
    return e.message ?? e.toString();
  }
  // Para cualquier otro tipo de error, convertimos a texto
  return e.toString();
}

// ── AppBar ────────────────────────────────────────────────────────────────────

// Crea la barra superior estándar de la app con el título y el icono de notificaciones.
// Se usa en todas las pantallas principales para mantener coherencia visual.
PreferredSizeWidget appMainAppBar({
  // Función que se ejecuta cuando el usuario pulsa el icono de notificaciones
  required VoidCallback onNotifications,
  // Número de notificaciones sin leer que se muestra encima del icono
  int numeroNotificaciones = 0,
  BuildContext? context,
}) {
  return AppBar(
    title: const Text('Cuidem-nos en xarxa', style: TextStyle(fontSize: 19)),
    centerTitle: true,
    actions: [
      // Mostramos el icono de notificaciones con el contador de no leídas
      _notificationBadge(
        numeroNotificaciones,
        Icons.notifications_active,
        onPressed: onNotifications,
        context: context,
      ),
    ],
  );
}

// Widget privado (solo para uso interno de este archivo) que muestra el icono de
// notificaciones con una burbuja roja encima indicando cuántas hay sin leer.
Widget _notificationBadge(
  int count,
  IconData icon, {
  required VoidCallback onPressed,
  BuildContext? context,
}) {
  // Obtenemos el texto del tooltip en el idioma activo, con "Notificaciones" como fallback
  final tooltip = context != null
      ? AppLocalizations.of(context)?.notifications ?? 'Notificaciones'
      : 'Notificaciones';
  return Badge(
    // El número encima del icono
    label: Text(count.toString()),
    alignment: Alignment.topLeft,
    child: IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      // Texto descriptivo que aparece al mantener el dedo sobre el icono (accesibilidad)
      tooltip: tooltip,
    ),
  );
}

// ── Buttons ───────────────────────────────────────────────────────────────────

// Botón relleno estándar de la app con animaciones de hover y pulsación.
// Se usa para las acciones principales como "Guardar", "Crear", etc.
Widget general_filledbutton(String texto, {required VoidCallback onPressed}) {
  return FilledButton(
    onPressed: onPressed,
    style: ButtonStyle(
      // Duración de la animación al pulsar el botón (más rápida que el valor por defecto)
      animationDuration: const Duration(milliseconds: 140),
      // Color de la capa encima del botón cuando se interactúa con él
      overlayColor: WidgetStateProperty.resolveWith((states) {
        // Al pulsar: oscurece el botón para dar sensación de presión física
        if (states.contains(WidgetState.pressed)) {
          return Colors.black.withValues(alpha: 0.16);
        }
        // Al pasar el ratón por encima (solo en escritorio): aclara ligeramente
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withValues(alpha: 0.10);
        }
        return null;
      }),
      // Sombra del botón según el estado de interacción
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return 0; // Sin sombra al pulsar
        if (states.contains(WidgetState.hovered)) return 3;  // Más sombra al hover
        return 1;                                             // Sombra normal en reposo
      }),
    ),
    child: Text(texto),
  );
}

// Botón flotante circular que aparece en la esquina inferior derecha de una pantalla.
// Se usa normalmente para la acción principal de creación (ej: "añadir nuevo trabajador").
Widget general_floatingbutton(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(onPressed: onPressed, child: Icon(icono));
}

// Botón de eliminación con color rojo adaptado al tema claro u oscuro.
// Se usa para confirmar acciones destructivas como borrar un registro.
Widget general_deletebutton(
  BuildContext context,
  String texto, {
  required VoidCallback onPressed,
}) {
  // Detectamos si el usuario tiene el tema oscuro activo para elegir el tono de rojo correcto
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      // Usamos el rojo oscuro o claro según el tema para mantener buen contraste
      backgroundColor: isDark ? AppPalette.errorDark : AppPalette.errorLight,
      foregroundColor:
          isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight,
    ),
    child: Text(texto),
  );
}

// ── Text fields ───────────────────────────────────────────────────────────────

// Campo de texto básico con icono opcional a la izquierda.
// Soporta modo contraseña (obscureText: true oculta los caracteres con puntos).
// Se usa principalmente en el formulario de login.
TextField general_textfield(
  String texto,       // Texto de ayuda que aparece cuando el campo está vacío
  bool obscureText, {  // true = ocultar caracteres (para contraseñas)
  IconData? icono,     // Icono opcional a la izquierda del campo
  double borderRadius = 12.0,
  int maxLines = 1,    // 1 = una línea; más de 1 = campo multilinea (ej: notas)
  TextEditingController? controller, // Controlador para leer o escribir el valor del campo
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: texto,
      // Solo añadimos el icono si se proporcionó uno
      prefixIcon: icono != null ? Icon(icono) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none, // Sin borde visible (el fondo de color ya lo delimita)
      ),
      filled: true,
    ),
  );
}

// Campo de formulario sin icono con soporte para validación.
// A diferencia del anterior, este pertenece a un Form y puede mostrar mensajes de error
// debajo del campo si el valor no cumple las reglas del validador.
TextFormField general_textfield_NoICON(
  String texto, {
  double borderRadius = 12.0,
  int maxLines = 1,
  TextEditingController? controller,
  bool enabled = true, // false = campo deshabilitado (solo lectura visual)
  // Función que valida el valor; devuelve null si es válido, o un mensaje de error si no lo es
  String? Function(String?)? validator,
  // Filtros opcionales que restringen qué caracteres se pueden escribir (ej: solo números)
  List<TextInputFormatter>? inputFormatters,
  // Tipo de teclado a mostrar en móvil (numérico, email, etc.)
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
      hintText: texto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

// Campo de búsqueda con bordes muy redondeados (estilo "píldora").
// Llama a onChanged cada vez que el usuario escribe una letra,
// lo que permite filtrar listas en tiempo real sin pulsar ningún botón.
TextField general_busqueda_textfield(
  String texto, {
  IconData? icono,
  double borderRadius = 50.0, // Radio muy alto para el efecto píldora
  TextEditingController? controller,
  // Se ejecuta automáticamente con cada cambio de texto para filtrar la lista
  ValueChanged<String>? onChanged,
}) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icono, color: AppPalette.primaryLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

// ── Snackbars ─────────────────────────────────────────────────────────────────

// Muestra una barra de mensaje informativa en la parte inferior de la pantalla.
// Desaparece automáticamente después del número de segundos indicado.
void general_snackbar(
  BuildContext context,
  String content,        // Texto del mensaje
  int durationSeconds,   // Cuántos segundos debe estar visible
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      duration: Duration(seconds: durationSeconds),
    ),
  );
}

// Igual que general_snackbar pero con fondo rojo para indicar que algo ha ido mal.
// Se usa para mostrar errores al usuario de forma llamativa pero no bloqueante.
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
          // Texto de color contrastante con el fondo de error
          color: Theme.of(context).colorScheme.onError,
          fontWeight: FontWeight.w600,
        ),
      ),
      duration: Duration(seconds: durationSeconds),
      // Fondo rojo del tema actual
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

// ── List tiles ────────────────────────────────────────────────────────────────

// Elemento de lista estándar con icono y texto para usar en menús o listas navegables.
// Si selected es true, se resalta con el color de superficie para indicar la pantalla activa.
Widget general_listtile({
  required BuildContext context,
  required IconData icon,
  required String texto,
  VoidCallback? onTap, // Acción al pulsar; null = no es pulsable
  bool selected = false, // true = resaltar como elemento activo (pantalla actual)
}) {
  // Color de fondo cuando el elemento está seleccionado
  final surfaceColor = Theme.of(context).colorScheme.surface;
  // Color de texto por defecto del tema actual
  final defaultTextColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

  return Container(
    decoration: BoxDecoration(
      // Fondo solo cuando está seleccionado; transparent para los no seleccionados
      color: selected ? surfaceColor : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
    ),
    child: ListTile(
      leading: Icon(icon, color: AppPalette.primaryLight),
      title: Text(
        texto,
        style: TextStyle(
          // El elemento seleccionado usa el color primario para destacar
          color: selected ? AppPalette.primaryLight : defaultTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    ),
  );
}

// Elemento de lista especial para el botón de cerrar sesión.
// Es más pequeño que general_listtile porque va en la parte inferior del drawer,
// donde hay menos espacio y el cierre de sesión es una acción secundaria.
Widget general_listtile_logout({
  required BuildContext context,
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(
    horizontalTitleGap: 2, // Reduce el espacio entre el icono y el texto
    leading: Icon(icon, color: AppPalette.primaryLight, size: 16), // Icono más pequeño
    title: Text(
      texto,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12), // Texto más pequeño
    ),
    onTap: onTap,
  );
}

// ── Dialogs ───────────────────────────────────────────────────────────────────

// Muestra un diálogo de confirmación con dos botones: cancelar y confirmar.
// Se usa antes de realizar acciones irreversibles (borrar un usuario, etc.)
// para que el usuario confirme que realmente quiere hacerlo.
Future<void> showConfirmDialog(
  BuildContext context, {
  required String title,        // Título del diálogo (ej: "Eliminar trabajador")
  required String content,      // Mensaje explicativo (ej: "Esta acción no se puede deshacer")
  required String confirmText,  // Texto del botón de confirmar (ej: "Eliminar")
  required String cancelText,   // Texto del botón de cancelar (ej: "Cancelar")
  required VoidCallback onConfirm, // Acción que se ejecuta si el usuario confirma
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        // Botón secundario que cierra el diálogo sin hacer nada
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(cancelText),
        ),
        // Botón principal que cierra el diálogo Y ejecuta la acción solicitada
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx); // Primero cerramos el diálogo
            onConfirm();        // Luego ejecutamos la acción confirmada
          },
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
