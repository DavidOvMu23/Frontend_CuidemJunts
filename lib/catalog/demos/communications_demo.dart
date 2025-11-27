import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_communications_demo.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_buttons_demo.dart';

// -------- DEMO: COMUNICACIONES --------
// Muestra los diferentes tipos de comunicaciones disponibles.
class CommunicationsDemo extends StatelessWidget {
  const CommunicationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con el título del demo
      appBar: AppBar(title: const Text('Demo: Communications')),

      // SingleChildScrollView para que el contenido sea scrollable
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),

        // Columna en la que se van a ir mostrando los widgets
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Badge con el número de notificaciones
            widget_badge_demo(
              5,
              Icons.notifications,
              onPressed: () {
                widget_snackbar_demo(context, "Click en Notificaciones", 2);
              },
            ),
            const SizedBox(height: 24),

            // Wrap sirve para que los botones se ajusten al ancho disponible
            Wrap(
              spacing: 10,
              children: [
                // Botón para mostrar un Snackbar
                widget_filledbutton_demo(
                  "Show Snackbar",
                  onPressed: () {
                    widget_snackbar_demo(
                      context,
                      "Operación realizada con éxito",
                      3,
                    );
                  },
                ),
                // Botón para mostrar un Snackbar de error
                widget_filledbutton_demo(
                  "Show Error Snackbar",
                  onPressed: () {
                    widget_snackbar_error_demo(
                      context,
                      "Ha ocurrido un error crítico",
                      3,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botón para mostrar un Dialog
            widget_filledbutton_demo(
              "Show Dialog",
              onPressed: () {
                widget_showConfirmDialog_demo(
                  context,
                  title: "Confirm Dialog Title",
                  content: "Dialog Content Text",
                  confirmText: "Confirm Action",
                  cancelText: "Cancel Action",
                  onConfirm: () {
                    widget_snackbar_demo(context, "Confirmado!", 2);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
