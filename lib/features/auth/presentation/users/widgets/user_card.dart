import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:intl/intl.dart';

// -------- TARJETA DE USUARIO --------
// Widget reutilizable que muestra la información de un usuario en formato de tarjeta.
// Incluye nombre, fecha de nacimiento, teléfono, dirección y nivel de dependencia.
class UserCard extends StatelessWidget {
  final Usuario usuario;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final DateFormat dateFormatter;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.usuario,
    required this.textTheme,
    required this.colorScheme,
    required this.dateFormatter,
    required this.onTap,
  });

  // Convierte el nivel de dependencia a un texto legible.
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
        return raw; // Si viene otro valor, mostramos tal cual.
    }
  }

  // Retorna el color de fondo según el nivel de dependencia y el tema actual.
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
        return colorScheme.surface;
    }
  }

  // Retorna el color del texto según el nivel de dependencia y el tema actual.
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
        return colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaNacimiento = dateFormatter.format(usuario.f_nac);
    final direccion = usuario.direccion.trim();
    final depBg = _dependenciaBg(context);
    final depText = _dependenciaText(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${usuario.nombre} ${usuario.apellidos}',
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    general_iconbutton(
                      Icons.edit,
                      onPressed: () {
                        // TODO: Implementar edición de usuario
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.cake, size: 18),
                    const SizedBox(width: 6),
                    Text(fechaNacimiento, style: textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 18),
                    const SizedBox(width: 6),
                    Text(usuario.telefono, style: textTheme.bodyMedium),
                  ],
                ),
                if (direccion.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(direccion, style: textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
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
                    _dependenciaTexto,
                    style: textTheme.bodySmall?.copyWith(
                      color: depText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
