import 'package:flutter/material.dart';
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 18),
                        const SizedBox(width: 6),
                        Text(widget.trabajador.rol, style: textTheme.bodyMedium),
                      ],
                    ),
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
