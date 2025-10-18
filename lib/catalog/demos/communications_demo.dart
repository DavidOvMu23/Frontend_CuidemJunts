import 'package:flutter/material.dart';

class CommunicationsDemo extends StatelessWidget {
  const CommunicationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // La parte de arriba de la app (barra con el título)
      appBar: AppBar(title: const Text('Demo: Communications')),

      // El cuerpo principal de la pantalla
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Usamos material como surface(el fondo azul)
        child: Material(
          borderRadius: BorderRadius.circular(16), // bordes redondeados

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // Wrap coloca los botones uno al lado del otro y baja de línea si no caben
            child: Wrap(
              spacing: 12, // Espacio horizontal entre elementos
              runSpacing: 12, // Espacio vertical entre filas
              children: [
                // Badge: muestra un icono con un número encima (como notificaciones)
                const Badge(
                  label: Text('10'), // Número que se muestra
                  child: Icon(Icons.notifications), // Icono debajo del número
                ),

                // Botón que al pulsarlo muestra un SnackBar (mensaje corto en la parte inferior)
                FilledButton(
                  onPressed: () {
                    // Cuando pulsamos, se muestra el mensaje
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Hola! Soy un SnackBar.'),
                        // El mensaje dura 2 segundos
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Mostrar SnackBar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
