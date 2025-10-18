import 'package:flutter/material.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // La parte de arriba de la app (barra con el título)
      appBar: AppBar(title: const Text('Demo: Buttons')),

      // El cuerpo principal de la pantalla
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Usamos material como surface(el fondo azul)
        child: Material(
          borderRadius: BorderRadius.circular(16), //Bordes redondeados

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // Wrap coloca los botones uno al lado del otro y baja de línea si no caben
            child: Wrap(
              spacing: 12, // Espacio entre botones horizontalmente
              runSpacing: 12, // Espacio entre filas verticalmente
              children: [
                // FilledButton = botón con fondo sólido
                FilledButton(
                  onPressed: () {},
                  child: const Text('Filled Button'),
                ),

                // FilledButton Tonal = botón con fondo menos llamativo
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Filled Tonal'),
                ),

                // OutlinedButton = botón con borde pero sin fondo
                TextButton(onPressed: () {}, child: const Text('Text Button')),

                // OutlinedButton = botón con borde pero sin fondo
                IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),

                // ElevatedButton = botón con sombra y icono
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
