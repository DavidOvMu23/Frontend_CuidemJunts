import 'package:flutter/material.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación con un título
      appBar: AppBar(title: const Text('Demo: Buttons')),

      body: Padding(
        // Padding: añade espacio alrededor de todo el contenido del body
        // En este caso, separa los botones de los bordes de la pantalla
        padding: const EdgeInsets.all(16.0),

        // Wrap: organiza los elementos uno al lado del otro
        // y los salta de línea automáticamente si no caben
        child: Wrap(
          spacing: 12, //Espacio horizontal entre los elementos
          runSpacing: 12, //Espacio vertical entre filas de elementos
          children: [
            //Bottón con relleno solido
            FilledButton(onPressed: () {}, child: const Text('Filled Button')),

            // Botón tonal
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Filled Tonal'),
            ),

            // Botón de texto
            TextButton(onPressed: () {}, child: const Text('Text Button')),

            // Botón de icono
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),

            // Botón flotante
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
