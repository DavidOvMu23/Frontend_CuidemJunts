import 'package:flutter/material.dart';

class TypographyDemo extends StatelessWidget {
  const TypographyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los estilos de texto
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Typography')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        // Usamos Align para colocar el surface a la izquierda
        child: Material(
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            //Column coloca los elementos uno debajo de otro
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // se adapta al contenido
              children: [
                Text('Título principal', style: textTheme.headlineLarge),
                const SizedBox(height: 8),

                Text('Subtítulo de sección', style: textTheme.titleMedium),
                const SizedBox(height: 8),

                Text(
                  'Este es un texto de cuerpo. Aquí iría una descripción o párrafo.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

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
