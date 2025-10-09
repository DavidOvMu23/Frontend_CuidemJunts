import 'package:flutter/material.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Buttons')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Wrap permite colocar los botones uno al lado del otro y que salten de línea si no caben
        child: Wrap(
          spacing: 12, // Espacio horizontal entre botones
          runSpacing: 12, // Espacio vertical entre botones

          children: [
            // Botón lleno (FilledButton)
            FilledButton(onPressed: () {}, child: const Text('Filled Button')),

            // Botón tonal (FilledButton.tonal)
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Filled Tonal'),
            ),

            // Botón de texto (TextButton)
            TextButton(onPressed: () {}, child: const Text('Text Button')),

            // Botón de icono (IconButton)
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),

            // Botón flotante (FloatingActionButton)
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
