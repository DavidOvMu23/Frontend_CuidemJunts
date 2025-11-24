import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:intl/intl.dart';

class UserDetailDialog extends StatelessWidget {
  final Usuario usuario;
  final DateFormat dateFormatter;
  final VoidCallback onDelete;

  const UserDetailDialog({
    super.key,
    required this.usuario,
    required this.dateFormatter,
    required this.onDelete,
  });

  String get _dependenciaTexto {
    final raw = usuario.nivelDependencia.trim();
    if (raw.isEmpty) return 'Sin especificar';
    final upper = raw.toUpperCase();
    switch (upper) {
      case 'G1':
      case 'LEVE':
        return 'Leve';
      case 'G2':
      case 'MODERADA':
      case 'MODERADO':
        return 'Moderada';
      case 'G3':
      case 'SEVERA':
      case 'SEVERO':
        return 'Severa';
      default:
        return raw;
    }
  }

  Color _dependenciaBg(BuildContext context) {
    final raw = usuario.nivelDependencia.trim().toUpperCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (raw) {
      case 'G1':
      case 'LEVE':
        return isDark ? AppPalette.successDark : AppPalette.successLight;
      case 'G2':
      case 'MODERADA':
      case 'MODERADO':
        return isDark ? AppPalette.warningDark : AppPalette.warningLight;
      case 'G3':
      case 'SEVERA':
      case 'SEVERO':
        return isDark ? AppPalette.errorDark : AppPalette.errorLight;
      default:
        return Theme.of(context).colorScheme.surface;
    }
  }

  Color _dependenciaText(BuildContext context) {
    final raw = usuario.nivelDependencia.trim().toUpperCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (raw) {
      case 'G1':
      case 'LEVE':
        return isDark
            ? AppPalette.successFontDark
            : AppPalette.successFontLight;
      case 'G2':
      case 'MODERADA':
      case 'MODERADO':
        return isDark
            ? AppPalette.warningFontDark
            : AppPalette.warningFontLight;
      case 'G3':
      case 'SEVERA':
      case 'SEVERO':
        return isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este usuario?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx); // Cerrar confirmación
              onDelete(); // Ejecutar eliminación
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fechaNacimiento = dateFormatter.format(usuario.f_nac);
    final depBg = _dependenciaBg(context);
    final depText = _dependenciaText(context);

    return AlertDialog(
      title: Text('${usuario.nombre} ${usuario.apellidos}'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DNI
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('DNI'),
                subtitle: Text(usuario.dni),
                contentPadding: EdgeInsets.zero,
              ),

              // Nombre completo (ya está en el título, pero lo incluyo por completitud)
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Nombre completo'),
                subtitle: Text('${usuario.nombre} ${usuario.apellidos}'),
                contentPadding: EdgeInsets.zero,
              ),

              // Fecha de nacimiento
              ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('Fecha de nacimiento'),
                subtitle: Text(fechaNacimiento),
                contentPadding: EdgeInsets.zero,
              ),

              // Teléfono
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Teléfono'),
                subtitle: Text(
                  usuario.telefono.isNotEmpty
                      ? usuario.telefono
                      : 'No especificado',
                ),
                contentPadding: EdgeInsets.zero,
              ),

              // Dirección
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Dirección'),
                subtitle: Text(
                  usuario.direccion.isNotEmpty
                      ? usuario.direccion
                      : 'No especificada',
                ),
                contentPadding: EdgeInsets.zero,
              ),

              // Estado de cuenta
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Estado de cuenta'),
                subtitle: Text(usuario.estadoCuenta),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),

              // Nivel de dependencia
              const Text(
                'Nivel de dependencia',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: depBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _dependenciaTexto,
                  style: textTheme.bodyMedium?.copyWith(
                    color: depText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Contactos de emergencia
              if (usuario.contactosEmergencia.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Contactos de emergencia',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...usuario.contactosEmergencia.map(
                  (contacto) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.contact_phone),
                      title: Text('${contacto.nombre} ${contacto.apellidos}'),
                      subtitle: Text(
                        '${contacto.relacion} - ${contacto.telefono}',
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        FilledButton(
          onPressed: () => _confirmarEliminacion(context),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
