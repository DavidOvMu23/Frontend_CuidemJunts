import 'package:flutter/material.dart';

// -------- WIDGET PRINCIPAL --------
// Esta clase muestra ejemplos de los diferentes estilos tipográficos
// que se pueden usar en Flutter a través del tema actual (Theme).
class TypographyDemo extends StatelessWidget {
  const TypographyDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    // -------- OBTENCIÓN DE ESTILOS DE TEXTO --------
    // Accedemos a los estilos de texto definidos en el tema actual (ThemeData)
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // -------- BARRA SUPERIOR (APPBAR) --------
      appBar: AppBar(title: const Text('Demo: Typography')),

      // -------- CUERPO PRINCIPAL --------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        // -------- SURFACE PRINCIPAL --------
        // Contenedor visual con bordes redondeados que agrupa los textos
        child: Material(
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // -------- COLUMNA DE TEXTOS --------
            // Muestra varios ejemplos de estilos tipográficos del tema
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Se ajusta al tamaño del contenido

              children: [
                // -------- TITULAR PRINCIPAL --------
                Text('Título principal', style: textTheme.headlineLarge),
                const SizedBox(height: 8),

                // -------- SUBTÍTULO --------
                Text('Subtítulo de sección', style: textTheme.titleMedium),
                const SizedBox(height: 8),

                // -------- TEXTO DE CUERPO --------
                Text(
                  'Este es un texto de cuerpo. Aquí iría una descripción o párrafo.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // -------- TEXTO PEQUEÑO / NOTA --------
                Text(
                  'Nota al pie o texto secundario.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
