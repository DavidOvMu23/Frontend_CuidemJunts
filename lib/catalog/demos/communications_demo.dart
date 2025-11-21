import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_communications_demo.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_buttons_demo.dart';

// -------- WIDGET PRINCIPAL --------
class CommunicationsDemo extends StatelessWidget {
  const CommunicationsDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Communications')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            widget_badge_demo(
              5,
              Icons.notifications,
              onPressed: () {
                widget_snackbar_demo(context, "Click en Notificaciones", 2);
              },
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              children: [
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
