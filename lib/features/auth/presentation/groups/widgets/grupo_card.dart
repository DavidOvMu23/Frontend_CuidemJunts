import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// Tarjeta que muestra la información resumida de un grupo: nombre, descripción,
// número de teleoperadores y si el grupo está activo o inactivo.
class GrupoCard extends StatefulWidget {
  // Los datos del grupo a mostrar
  final Grupo grupo;
  // Función que se ejecuta cuando el usuario pulsa la tarjeta
  final VoidCallback onTap;

  const GrupoCard({
    super.key,
    required this.grupo,
    required this.onTap,
  });

  @override
  State<GrupoCard> createState() => _GrupoCardState();
}

class _GrupoCardState extends State<GrupoCard> {
  // Controla si el ratón está encima de la tarjeta para el efecto de elevación
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    // Quitamos espacios al inicio y al final de la descripción antes de mostrarlo
    final descripcion = widget.grupo.descripcion.trim();

    // Animación suave al pasar el ratón por encima
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      // Sube 2 píxeles cuando el ratón está encima
      transform: Matrix4.translationValues(0.0, _hovered ? -2.0 : 0.0, 0.0),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        // La sombra solo aparece cuando el ratón está encima
        elevation: _hovered ? 3 : 0,
        shadowColor: colorScheme.primary.withValues(alpha: 0.22),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          // Detecta cuándo el ratón entra o sale para animar la tarjeta
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
                    // Nombre del grupo en grande
                    Text(
                      widget.grupo.nombre,
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // La descripción solo se muestra si el grupo tiene una (no está vacía)
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              descripcion,
                              style: textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    // Número de teleoperadores asignados a este grupo
                    Row(
                      children: [
                        const Icon(Icons.support_agent_outlined, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.grupo.teleoperadoresCount} ${l10n.telemarketers.toLowerCase()}',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Badge verde/rojo que indica si el grupo está activo o no
                    _GrupoActiveBadge(activo: widget.grupo.activo),
                  ],
                ),
              ),
              // Flecha a la derecha para indicar que es clicable
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
      ),
    );
  }
}

// Badge pequeño que muestra "Activo" en verde o "Inactivo" en rojo
class _GrupoActiveBadge extends StatelessWidget {
  // true = grupo activo, false = grupo inactivo
  final bool activo;
  const _GrupoActiveBadge({required this.activo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Color de fondo: verde si activo, rojo si inactivo (versión clara u oscura según el tema)
    final bg = activo
        ? (isDark ? AppPalette.successDark : AppPalette.successLight)
        : (isDark ? AppPalette.errorDark : AppPalette.errorLight);
    // Color del texto con contraste adecuado sobre el fondo
    final fg = activo
        ? (isDark ? AppPalette.successFontDark : AppPalette.successFontLight)
        : (isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        activo ? l10n.active : l10n.inactive,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
