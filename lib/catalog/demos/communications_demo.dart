import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widget_badge_demo.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widget_filledbutton_demo.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widget_snackbar_demo.dart';

// -------- WIDGET PRINCIPAL --------
// Esta clase muestra ejemplos de comunicación visual en Flutter,
// como notificaciones y mensajes breves tipo SnackBar.
class CommunicationsDemo extends StatelessWidget {
  const CommunicationsDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------- BARRA SUPERIOR (APPBAR) --------
      // Contiene el título de la pantalla en la parte superior
      appBar: AppBar(title: const Text('Demo: Communications')),

      // -------- CUERPO PRINCIPAL --------
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // -------- PANEL PRINCIPAL (SURFACE) --------
        // Contenedor visual con bordes redondeados
        child: Material(
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            // -------- CONTENEDOR DE ELEMENTOS --------
            // Wrap acomoda los elementos horizontalmente y los pasa a la siguiente fila si no caben.
            child: Wrap(
              spacing: 12, // Espacio horizontal entre elementos
              runSpacing: 12, // Espacio vertical entre filas

              children: [
                // -------- BADGE --------
                // Muestra un ícono con un número encima, como las notificaciones de una app.
                widget_badge_demo(10, Icons.notifications, onPressed: () {}),

                // -------- FILLED BUTTON (SnackBar) --------
                // Botón que al pulsarlo muestra un mensaje corto (SnackBar) en la parte inferior.
                widget_filledbutton_demo(
                  'Mostrar SnackBar',
                  onPressed: () {
                    widget_snackbar_demo(context, '¡Hola desde SnackBar!', 2);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
