import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// Tarjeta que muestra la información resumida de un usuario: nombre, fecha
// de nacimiento, teléfono, dirección y nivel de dependencia con un badge de color.
class UserCard extends StatefulWidget {
  // Los datos del usuario a mostrar
  final Usuario usuario;
  // Estilos de texto y colores compartidos desde la pantalla padre
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  // Formato para mostrar la fecha de nacimiento (p. ej. "dd/MM/yyyy")
  final DateFormat dateFormatter;
  // Función que se ejecuta cuando el usuario pulsa la tarjeta
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.usuario,
    required this.textTheme,
    required this.colorScheme,
    required this.dateFormatter,
    required this.onTap,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  // Controla si el ratón está encima de la tarjeta para activar el efecto de elevación
  bool _hovered = false;

  // Traduce el código de dependencia (G1, G2...)
  String _dependenciaTexto(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final raw = widget.usuario.nivelDependencia.trim();
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

  // Asigna un color de fondo según la severidad de la dependencia
  Color _dependenciaBg(BuildContext context) {
    final raw = widget.usuario.nivelDependencia.trim().toUpperCase();
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
        return Theme.of(context).colorScheme.surfaceContainerHighest;
      default:
        return widget.colorScheme.surface;
    }
  }

  // Asigna el color del texto para asegurar contraste con el fondo
  Color _dependenciaText(BuildContext context) {
    final raw = widget.usuario.nivelDependencia.trim().toUpperCase();
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
        return Theme.of(context).colorScheme.onSurface;
      default:
        return widget.colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formateamos la fecha de nacimiento con el formato configurado
    final fechaNacimiento = widget.dateFormatter.format(widget.usuario.f_nac);
    final direccion = widget.usuario.direccion.trim();

    // Calculamos los colores del badge de dependencia antes de pintar la tarjeta
    final depBg = _dependenciaBg(context);
    final depText = _dependenciaText(context);

    // La tarjeta sube 2 píxeles al pasar el ratón para indicar que es interactiva
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0.0, _hovered ? -2.0 : 0.0, 0.0),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        // La sombra aparece solo cuando el ratón está encima
        elevation: _hovered ? 3 : 0,
        shadowColor: widget.colorScheme.primary.withValues(alpha: 0.22),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          // Actualizamos el estado de hover para disparar la animación
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
                    // Nombre del usuario
                    Text(
                      '${widget.usuario.nombre} ${widget.usuario.apellidos}',
                      style: widget.textTheme.headlineLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Datos personales
                    Row(
                      children: [
                        const Icon(Icons.cake, size: 18),
                        const SizedBox(width: 6),
                        Text(fechaNacimiento, style: widget.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.usuario.telefono,
                          style: widget.textTheme.bodyMedium,
                        ),
                      ],
                    ),

                    // Dirección (solo si existe)
                    if (direccion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              direccion,
                              style: widget.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Badge de dependencia
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: depBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _dependenciaTexto(context),
                        style: widget.textTheme.bodySmall?.copyWith(
                          color: depText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Flecha (Centrada verticalmente a la derecha)
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
