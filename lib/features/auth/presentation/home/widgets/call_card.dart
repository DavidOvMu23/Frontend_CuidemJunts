import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// Tarjeta que muestra la información de una llamada
class CallCard extends StatelessWidget {
  final String? usuarioNombre;
  final String? usuarioApellidos;
  final String? grupoNombre;
  final String hora;
  final String? estado;

  const CallCard({
    super.key,
    this.usuarioNombre,
    this.usuarioApellidos,
    this.grupoNombre,
    required this.hora,
    this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(top: 8.0, bottom: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del paciente
            if (usuarioNombre != null)
              Text(
                '$usuarioNombre${usuarioApellidos != null ? ' $usuarioApellidos' : ''}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            if (usuarioNombre != null) const SizedBox(height: 4),

            // Grupo
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  grupoNombre ?? l10n.noGroup,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Hora
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  hora,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Estado
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getEstadoColor(estado, isDark: isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getEstadoTexto(estado, l10n),
                  style: textTheme.bodySmall?.copyWith(
                    color: _getEstadoTextColor(estado, isDark: isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funciones helper para colores
  String _getEstadoTexto(String? estado, AppLocalizations l10n) {
    if (estado == null || estado.trim().isEmpty) return l10n.noStatus;
    final upper = estado.trim().toUpperCase();
    switch (upper) {
      case 'COMPLETADA':
      case 'COMPLETED':
        return l10n.callCompleted;
      case 'PENDIENTE':
      case 'PENDING':
        return l10n.callPending;
      case 'CANCELADA':
      case 'CANCELLED':
      case 'CANCELED':
        return l10n.callCancelled;
      case 'NO_CONTESTO':
      case 'NO_ANSWER':
        return l10n.callNoAnswer;
      default:
        return estado.trim();
    }
  }

  Color _getEstadoColor(String? estado, {required bool isDark}) {
    if (estado == null || estado.trim().isEmpty) {
      return isDark ? Colors.grey[800]! : Colors.grey[300]!;
    }
    final upper = estado.trim().toUpperCase();
    switch (upper) {
      case 'COMPLETADA':
      case 'COMPLETED':
        return isDark ? AppPalette.successDark : AppPalette.successLight;
      case 'PENDIENTE':
      case 'PENDING':
        return isDark ? AppPalette.warningDark : AppPalette.warningLight;
      case 'CANCELADA':
      case 'CANCELLED':
      case 'CANCELED':
        return isDark ? Colors.grey[800]! : Colors.grey[300]!;
      case 'NO_CONTESTO':
      case 'NO_ANSWER':
        return isDark ? AppPalette.errorDark : AppPalette.errorLight;
      default:
        return isDark ? Colors.grey[800]! : Colors.grey[300]!;
    }
  }

  Color _getEstadoTextColor(String? estado, {required bool isDark}) {
    if (estado == null || estado.trim().isEmpty) {
      return isDark ? Colors.grey[300]! : Colors.grey[700]!;
    }
    final upper = estado.trim().toUpperCase();
    switch (upper) {
      case 'COMPLETADA':
      case 'COMPLETED':
        return isDark
            ? AppPalette.successFontDark
            : AppPalette.successFontLight;
      case 'PENDIENTE':
      case 'PENDING':
        return isDark
            ? AppPalette.warningFontDark
            : AppPalette.warningFontLight;
      case 'CANCELADA':
      case 'CANCELLED':
      case 'CANCELED':
        return isDark ? Colors.grey[300]! : Colors.grey[700]!;
      case 'NO_CONTESTO':
      case 'NO_ANSWER':
        return isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight;
      default:
        return isDark ? Colors.grey[300]! : Colors.grey[700]!;
    }
  }
}
