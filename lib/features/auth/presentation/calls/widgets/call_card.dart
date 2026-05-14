import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';

// Tarjeta individual de una llamada
class CallCard extends StatefulWidget {
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

  @override
  State<CallCard> createState() => _CallCardState();
}

class _CallCardState extends State<CallCard> {
  bool _hovered = false;

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

  String _estadoTexto(AppLocalizations l10n) {
    final estado = widget.llamada.estado.toLowerCase();
    if (estado.contains('completada')) {
      return l10n.callCompleted;
    } else if (estado.contains('pendiente')) {
      return l10n.callPending;
    } else if (estado.contains('no contestada') ||
        estado.contains('no contestó') ||
        estado.contains('no_contesto')) {
      return l10n.callNoAnswer;
    }
    if (widget.llamada.estado.isEmpty) return '';

    final limpio = widget.llamada.estado.replaceAll('_', ' ');
    return limpio[0].toUpperCase() + limpio.substring(1);
  }

  Color _getStatusColor(BuildContext context) {
    final estado = widget.llamada.estado.toLowerCase();
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
    return widget.colorScheme.surfaceContainerHighest;
  }

  Color _getStatusTextColor(BuildContext context) {
    final estado = widget.llamada.estado.toLowerCase();
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
    return widget.colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateText = _formatDate(widget.llamada.fecha);
    final durationText = _formatDuration(widget.llamada.duracion);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0.0, _hovered ? -2.0 : 0.0, 0.0),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: _hovered ? 3 : 0,
        shadowColor: widget.colorScheme.primary.withValues(alpha: 0.22),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onHover: (value) {
            if (_hovered == value) return;
            setState(() => _hovered = value);
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 40, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      widget.llamada.resumen.isNotEmpty
                          ? widget.llamada.resumen
                          : l10n.noSummary,
                      style: widget.textTheme.headlineLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Grupo
                    Row(
                      children: [
                        const Icon(Icons.group_outlined, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.llamada.grupoNombre?.isNotEmpty == true
                                ? widget.llamada.grupoNombre!
                                : l10n.noGroupAssigned,
                            style: widget.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (widget.llamada.teleoperadorNombre != null && widget.llamada.teleoperadorNombre!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.support_agent_outlined, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${widget.llamada.teleoperadorNombre} ${widget.llamada.teleoperadorApellidos ?? ''}',
                              style: widget.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),

                    // Fecha y Duración
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateText,
                          style: widget.textTheme.bodyMedium?.copyWith(
                            color: widget.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          durationText,
                          style: widget.textTheme.bodyMedium?.copyWith(
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
                        _estadoTexto(l10n),
                        style: widget.textTheme.bodySmall?.copyWith(
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
                    color: widget.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
