import 'package:flutter/material.dart';

class CommunicationsDemo extends StatelessWidget {
  const CommunicationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación con un título
      appBar: AppBar(title: const Text('Demo: Communications')),
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
            // Badge de notificaciones
            const Badge(
              //número de notificaciones
              label: Text('10'),
              //icono a mostrar
              child: Icon(Icons.notifications),
            ),

            // Snackbar
            //creamos un botón
            FilledButton(
              child: const Text('Mostrar SnackBar'), //texto del botón
              //cuando pulsemos en el botón mostraremnos el snackbar
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hola soy el snackbar!'), //texto
                    duration: Duration(seconds: 2), //duración
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
