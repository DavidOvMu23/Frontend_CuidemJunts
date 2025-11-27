import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';

// Tarjeta individual de una llamada
class CallCard extends StatelessWidget {
  final Llamadas llamada;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const CallCard({
    super.key,
    required this.llamada,
    required this.textTheme,
    required this.colorScheme,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sept',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // para esto nos a ayudado un poco el chat
  String _formatDuration(String duration) {
    if (duration.toLowerCase().contains('min')) return duration;

    try {
      if (duration.contains(':')) {
        final parts = duration.split(':');
        if (parts.length >= 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          return '$minutes min';
        }
      }
      // Si es solo un número, asumimos minutos
      if (int.tryParse(duration) != null) {
        return '$duration min';
      }
    } catch (_) {}

    // Fallback: si no está vacío, añadimos min
    if (duration.isNotEmpty) return '$duration min';
    return duration;
  }

  String get _estadoTexto {
    final estado = llamada.estado.toLowerCase();
    if (estado.contains('completada')) {
      return 'Completada';
    } else if (estado.contains('pendiente')) {
      return 'Pendiente';
    } else if (estado.contains('no contestada') ||
        estado.contains('no contestó') ||
        estado.contains('no_contesto')) {
      return 'No contestó';
    }
    if (llamada.estado.isEmpty) return '';

    // Reemplazamos guiones bajos por espacios y capitalizamos
    final limpio = llamada.estado.replaceAll('_', ' ');
    return limpio[0].toUpperCase() + limpio.substring(1);
  }

  Color _getStatusColor(BuildContext context) {
    final estado = llamada.estado.toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (estado.contains('completada')) {
      return isDark ? AppPalette.successDark : AppPalette.successLight;
    } else if (estado.contains('pendiente')) {
      return isDark ? AppPalette.warningDark : AppPalette.warningLight;
    } else if (estado.contains('no contestada') ||
        estado.contains('no contestó') ||
        estado.contains('no_contesto')) {
      return isDark ? AppPalette.errorDark : AppPalette.errorLight;
    }
    return colorScheme.surfaceContainerHighest;
  }

  Color _getStatusTextColor(BuildContext context) {
    final estado = llamada.estado.toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (estado.contains('completada')) {
      return isDark ? AppPalette.successFontDark : AppPalette.successFontLight;
    } else if (estado.contains('pendiente')) {
      return isDark ? AppPalette.warningFontDark : AppPalette.warningFontLight;
    } else if (estado.contains('no contestada') ||
        estado.contains('no contestó') ||
        estado.contains('no_contesto')) {
      return isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight;
    }
    return colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(llamada.fecha);
    final durationText = _formatDuration(llamada.duracion);

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 40, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    llamada.resumen.isNotEmpty
                        ? llamada.resumen
                        : 'Sin resumen',
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Grupo / Usuario
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          llamada.grupoNombre?.isEmpty ?? true
                              ? 'Sin grupo asignado'
                              : 'Tel. ${llamada.grupoNombre}',
                          style: textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Fecha y Duración
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        durationText,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(
                            0xFF4ADE80,
                          ), // Verde brillante tipo Tailwind green-400
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Badge de estado de la llamada
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _estadoTexto,
                      style: textTheme.bodySmall?.copyWith(
                        color: _getStatusTextColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Flecha simplemente para indicar que la tarjeta es clicable
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
