import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/trabajador.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

class WorkerCard extends StatefulWidget {
  final Trabajador trabajador;
  final VoidCallback onTap;

  const WorkerCard({
    super.key,
    required this.trabajador,
    required this.onTap,
  });

  @override
  State<WorkerCard> createState() => _WorkerCardState();
}

class _WorkerCardState extends State<WorkerCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final grupo = (widget.trabajador.grupoNombre ?? '').trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0.0, _hovered ? -2.0 : 0.0, 0.0),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: _hovered ? 3 : 0,
        shadowColor: colorScheme.primary.withValues(alpha: 0.22),
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
                    Text(
                      '${widget.trabajador.nombre} ${widget.trabajador.apellidos}',
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.trabajador.correo,
                            style: textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (widget.trabajador.rol.toLowerCase() != 'supervisor') ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.group_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            grupo.isEmpty ? l10n.noGroupAssigned : grupo,
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _RolBadge(rol: widget.trabajador.rol),
                        const SizedBox(width: 8),
                        _ActiveBadge(activo: widget.trabajador.activo),
                      ],
                    ),
                  ],
                ),
              ),
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

class _RolBadge extends StatelessWidget {
  final String rol;
  const _RolBadge({required this.rol});

  @override
  Widget build(BuildContext context) {
    final isSupervisor = rol.toLowerCase() == 'supervisor';
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSupervisor ? colorScheme.primary : colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSupervisor ? Icons.manage_accounts_outlined : Icons.headset_mic_outlined,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            rol,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool activo;
  const _ActiveBadge({required this.activo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = activo
        ? (isDark ? AppPalette.successDark : AppPalette.successLight)
        : (isDark ? AppPalette.errorDark : AppPalette.errorLight);
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
