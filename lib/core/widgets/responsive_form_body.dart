// Paquete principal de Flutter
import 'package:flutter/material.dart';
// Breakpoints para adaptar el diseño según el tamaño de pantalla
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

// -------- CONTENEDOR RESPONSIVO PARA FORMULARIOS --------
// Este widget envuelve cualquier formulario y le da el encabezado estándar
// (título + subtítulo opcional) y ajusta el padding según si estamos en
// móvil/tablet o en escritorio.
//
// Usarlo en todos los formularios garantiza que todos tienen el mismo aspecto
// y que responden bien a diferentes tamaños de pantalla sin repetir código.
class ResponsiveFormBody extends StatelessWidget {
  // Título principal del formulario (ej: "Nuevo trabajador")
  final String title;
  // Subtítulo opcional con más información (ej: "Rellena los datos del nuevo trabajador")
  final String? subtitle;
  // El formulario en sí que se muestra dentro del contenedor
  final Widget form;

  const ResponsiveFormBody({super.key, required this.title, this.subtitle, required this.form});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ancho actual de la pantalla para adaptar el diseño
    final width = MediaQuery.of(context).size.width;
    // true si la pantalla es lo suficientemente ancha para el diseño de escritorio
    final isDesktop = width >= AppBreakpoints.desktop;
    // En escritorio damos un poco más de padding horizontal que en móvil
    final horizontalPadding = isDesktop ? 16.0 : 12.0;

    // SafeArea asegura que el contenido no quede tapado por el notch del móvil
    // o la barra de estado del sistema operativo
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del formulario con tamaño de fuente aumentado respecto al estilo base
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 27)),
            // El subtítulo solo se muestra si se proporcionó uno (es opcional)
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 20),
            // Expanded hace que el formulario ocupe todo el espacio vertical restante
            // sin que el usuario necesite hacer scroll en el contenedor exterior
            Expanded(
              child: Material(
                // Esquinas redondeadas del panel que contiene el formulario
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  // El formulario real pasado como parámetro
                  child: form,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
