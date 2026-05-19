import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// Ventana emergente con todos los detalles de un usuario: datos personales,
// nivel de dependencia, datos médicos y contactos de emergencia asignados.
class UserDetailDialog extends StatelessWidget {
  // Los datos completos del usuario a mostrar
  final Usuario usuario;
  // Formato para mostrar la fecha de nacimiento
  final DateFormat dateFormatter;
  // Funciones opcionales para eliminar o editar — si son nulas, los botones no aparecen
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  // Lista de contactos de emergencia canónicos (con datos completos desde el servidor)
  // Si es nula, se usan los contactos que vienen dentro del objeto usuario
  final List<ContactoEmergencia>? contactosCanonicos;

  const UserDetailDialog({
    super.key,
    required this.usuario,
    required this.dateFormatter,
    this.onDelete,
    this.onEdit,
    this.contactosCanonicos,
  });

  // Traduce el código de dependencia (G1, G2...) al texto legible en el idioma activo
  String _dependenciaTexto(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final raw = usuario.nivelDependencia.trim();
    if (raw.isEmpty) return l10n.sinEspecificar;
    final upper = raw.toUpperCase();
    switch (upper) {
      case 'G1':
      case 'LEVE':
        return l10n.mild;
      case 'G2':
      case 'MODERADA':
      case 'MODERADO':
        return l10n.moderate;
      case 'G3':
      case 'SEVERA':
      case 'SEVERO':
        return l10n.grave;
      case 'NINGUNA':
      case 'SIN DEPENDENCIA':
        return l10n.none;
      default:
        return raw;
    }
  }

  // Devuelve el color de fondo del badge de dependencia según el nivel (verde, naranja, rojo)
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
      case 'NINGUNA':
      case 'SIN DEPENDENCIA':
        return Theme.of(context).colorScheme.secondaryContainer;
      default:
        return Theme.of(context).colorScheme.surface;
    }
  }

  // Devuelve el color del texto del badge para garantizar contraste con el fondo
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
      case 'NINGUNA':
      case 'SIN DEPENDENCIA':
        return Theme.of(context).colorScheme.onSecondaryContainer;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  // Muestra un segundo diálogo de confirmación antes de borrar el usuario,
  // para evitar eliminaciones accidentales
  void _confirmarEliminacion(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteUserTitle),
        content: Text(l10n.deleteUserContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          general_deletebutton(
            ctx,
            l10n.delete,
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
          ),
        ],
      ),
    );
  }

  // Crea una fila reutilizable con icono, etiqueta y valor para mostrar
  // cada campo del detalle del usuario (nombre, DNI, teléfono, etc.)
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    // Formateamos la fecha de nacimiento antes de mostrarla
    final fechaNacimiento = dateFormatter.format(usuario.f_nac);
    // Preparamos los colores del badge de dependencia
    final depBg = _dependenciaBg(context);
    final depText = _dependenciaText(context);
    // Usamos los contactos canónicos si los hay; si no, los que trae el objeto usuario
    final contactos = contactosCanonicos ?? usuario.contactosEmergencia;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              '${usuario.nombre} ${usuario.apellidos}',
              style: textTheme.headlineLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              softWrap: true,
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                onEdit!();
              },
              icon: const Icon(Icons.edit, size: 20),
              tooltip: l10n.edit,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // DNI
              _buildDetailRow(
                context,
                Icons.badge_outlined,
                l10n.dni,
                usuario.dni,
              ),

              // Nombre completo
              _buildDetailRow(
                context,
                Icons.person_outline,
                l10n.fullName,
                '${usuario.nombre} ${usuario.apellidos}',
              ),

              // Fecha de nacimiento
              _buildDetailRow(
                context,
                Icons.cake_outlined,
                l10n.birthDate,
                fechaNacimiento,
              ),

              // Teléfono
              _buildDetailRow(
                context,
                Icons.phone_outlined,
                l10n.telephone,
                usuario.telefono.isNotEmpty
                    ? usuario.telefono
                    : l10n.notSpecified,
              ),

              // Dirección
              _buildDetailRow(
                context,
                Icons.location_on_outlined,
                l10n.address,
                usuario.direccion.isNotEmpty
                    ? usuario.direccion
                    : l10n.notSpecifiedFeminine,
              ),

              // Información
              if (usuario.informacion.isNotEmpty)
                _buildDetailRow(
                  context,
                  Icons.info_outline,
                  l10n.information,
                  usuario.informacion,
                ),

              // Datos médicos
              if (usuario.datosMedicosDolencias != null &&
                  usuario.datosMedicosDolencias!.isNotEmpty)
                _buildDetailRow(
                  context,
                  Icons.medical_services_outlined,
                  l10n.medicalData,
                  usuario.datosMedicosDolencias!,
                ),

              // Medicación
              if (usuario.medicacion != null && usuario.medicacion!.isNotEmpty)
                _buildDetailRow(
                  context,
                  Icons.medication_outlined,
                  l10n.medication,
                  usuario.medicacion!,
                ),

              const SizedBox(height: 8),

              // Nivel de dependencia
              Text(
                l10n.dependencyLevel,
                style: textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: depBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _dependenciaTexto(context),
                  style: textTheme.titleMedium?.copyWith(
                    color: depText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Contactos de emergencia
              if (contactos.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.emergencyContacts,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...contactos.map(
                  (contacto) => Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.contact_phone_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${contacto.nombre} ${contacto.apellidos}',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${contacto.telefono}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Builder(builder: (context) {
                                  final isUsuario = (contacto.dniUsuarioRef ?? '').isNotEmpty;
                                  final isDark = Theme.of(context).brightness == Brightness.dark;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isUsuario
                                          ? (isDark ? AppPalette.successDark : AppPalette.successLight)
                                          : (isDark ? AppPalette.warningDark : AppPalette.warningLight),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isUsuario ? Icons.verified_user_outlined : Icons.person_outline,
                                          size: 12,
                                          color: isUsuario
                                              ? (isDark ? AppPalette.successFontDark : AppPalette.successFontLight)
                                              : (isDark ? AppPalette.warningFontDark : AppPalette.warningFontLight),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isUsuario ? l10n.systemUser : l10n.externalContact,
                                          style: textTheme.bodySmall?.copyWith(
                                            fontSize: 11,
                                            color: isUsuario
                                                ? (isDark ? AppPalette.successFontDark : AppPalette.successFontLight)
                                                : (isDark ? AppPalette.warningFontDark : AppPalette.warningFontLight),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
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
          child: Text(l10n.close),
        ),
        if (onDelete != null)
          general_deletebutton(
            context,
            l10n.delete,
            onPressed: () => _confirmarEliminacion(context),
          ),
      ],
    );
  }
}
