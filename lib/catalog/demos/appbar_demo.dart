import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_communications_demo.dart';

// -------- DEMO: APP SHELL --------
// Muestra el AppBar estándar con badge de notificaciones
// y el Drawer reutilizable con opciones y logout.
class AppbarDemo extends StatelessWidget {
  const AppbarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar de demo con badge de la carpeta catalog/widgets
      appBar: AppBar(
        title: const Text('CuidemJunts'),
        centerTitle: true,
        actions: [widget_badge_demo(10, Icons.notifications, onPressed: () {})],
      ),
    );
  }
}
