import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

/// Extrae el mensaje de error legible de una excepción Dio / NestJS.
String extractErrorMessage(dynamic e) {
  if (e is DioException) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        if (msg is List) return msg.join(', ');
        return msg.toString();
      }
      if (data != null) return data.toString();
    } catch (_) {}
    return e.message ?? e.toString();
  }
  return e.toString();
}

// ── AppBar ────────────────────────────────────────────────────────────────────

PreferredSizeWidget appMainAppBar({
  required VoidCallback onNotifications,
  int numeroNotificaciones = 0,
  BuildContext? context,
}) {
  return AppBar(
    title: const Text('Cuidem-nos en xarxa', style: TextStyle(fontSize: 19)),
    centerTitle: true,
    actions: [
      _notificationBadge(
        numeroNotificaciones,
        Icons.notifications_active,
        onPressed: onNotifications,
        context: context,
      ),
    ],
  );
}

Widget _notificationBadge(
  int count,
  IconData icon, {
  required VoidCallback onPressed,
  BuildContext? context,
}) {
  final tooltip = context != null
      ? AppLocalizations.of(context)?.notifications ?? 'Notificaciones'
      : 'Notificaciones';
  return Badge(
    label: Text(count.toString()),
    alignment: Alignment.topLeft,
    child: IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
    ),
  );
}

// ── Buttons ───────────────────────────────────────────────────────────────────

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

Widget general_floatingbutton(
  IconData icono, {
  required VoidCallback onPressed,
}) {
  return FloatingActionButton(onPressed: onPressed, child: Icon(icono));
}

Widget general_deletebutton(
  BuildContext context,
  String texto, {
  required VoidCallback onPressed,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: isDark ? AppPalette.errorDark : AppPalette.errorLight,
      foregroundColor:
          isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight,
    ),
    child: Text(texto),
  );
}

// ── Text fields ───────────────────────────────────────────────────────────────

/// Campo de texto básico con icono opcional y soporte para obscureText.
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
      hintText: texto,
      prefixIcon: icono != null ? Icon(icono) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

/// Campo de formulario con soporte para validación.
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
      hintText: texto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
  );
}

/// Campo de búsqueda con border radius redondeado.
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

// ── List tiles ────────────────────────────────────────────────────────────────

Widget general_listtile({
  required BuildContext context,
  required IconData icon,
  required String texto,
  VoidCallback? onTap,
  bool selected = false,
}) {
  final surfaceColor = Theme.of(context).colorScheme.surface;
  final defaultTextColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

  return Container(
    decoration: BoxDecoration(
      color: selected ? surfaceColor : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
    ),
    child: ListTile(
      leading: Icon(icon, color: AppPalette.primaryLight),
      title: Text(
        texto,
        style: TextStyle(
          color: selected ? AppPalette.primaryLight : defaultTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    ),
  );
}

Widget general_listtile_logout({
  required BuildContext context,
  required IconData icon,
  required String texto,
  required VoidCallback onTap,
}) {
  return ListTile(
    horizontalTitleGap: 2,
    leading: Icon(icon, color: AppPalette.primaryLight, size: 16),
    title: Text(
      texto,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
    ),
    onTap: onTap,
  );
}

// ── Dialogs ───────────────────────────────────────────────────────────────────

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
