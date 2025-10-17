import 'package:flutter/material.dart';

class TypographyDemo extends StatelessWidget {
  const TypographyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Typography')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text('Nota al pie o caption', style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
