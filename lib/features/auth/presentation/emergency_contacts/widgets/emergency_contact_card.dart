import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

class EmergencyContactCard extends StatefulWidget {
  final ContactoEmergencia contacto;
  final List<String> asociados;
  final VoidCallback onTap;

  const EmergencyContactCard({
    super.key,
    required this.contacto,
    required this.asociados,
    required this.onTap,
  });

  @override
  State<EmergencyContactCard> createState() => _EmergencyContactCardState();
}

class _EmergencyContactCardState extends State<EmergencyContactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isUsuario = (widget.contacto.dniUsuarioRef ?? '').isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      '${widget.contacto.nombre} ${widget.contacto.apellidos}',
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18),
                        const SizedBox(width: 6),
                        Text(widget.contacto.telefono, style: textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.badge_outlined, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${l10n.users}: ${widget.asociados.isEmpty ? '-' : widget.asociados.join(', ')}',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            size: 13,
                            color: isUsuario
                                ? (isDark ? AppPalette.successFontDark : AppPalette.successFontLight)
                                : (isDark ? AppPalette.warningFontDark : AppPalette.warningFontLight),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUsuario ? l10n.systemUser : l10n.externalContact,
                            style: textTheme.bodySmall?.copyWith(
                              color: isUsuario
                                  ? (isDark ? AppPalette.successFontDark : AppPalette.successFontLight)
                                  : (isDark ? AppPalette.warningFontDark : AppPalette.warningFontLight),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
