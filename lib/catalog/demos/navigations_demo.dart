import 'package:flutter/material.dart';

// Widget principal que muestra una demo del Navigation Drawer
class NavigationsDemo extends StatelessWidget {
  const NavigationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación con un título
      appBar: AppBar(title: const Text('Demo: Navigation Drawer')),

      // Drawer: panel lateral que se puede abrir desde el borde izquierdo
      drawer: Drawer(
        // ListView: lista desplazable para los elementos del menú
        child: ListView(
          children: [
            // Cabecera del Drawer (parte superior del menú)
            const DrawerHeader(
              // Texto que se muestra en la cabecera
              child: Text('Cuidem Junts', style: TextStyle(fontSize: 24)),
            ),

            // Primer botón del Drawer: "Inicio"
            ListTile(
              leading: const Icon(Icons.home), // Ícono que acompaña el texto
              title: const Text('Inicio'), // Texto del botón
              onTap: () {
                // Acción al pulsar: cierra el Drawer
                Navigator.pop(context);
              },
            ),

            // Segundo botón: "Configuración"
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                // También cierra el Drawer al pulsar
                Navigator.pop(context);
              },
            ),

            // Tercer botón: "Acerca de"
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () {
                // Cierra el Drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // Contenido principal de la pantalla
      body: const Center(
        child: Text(
          'Bienvenido a la demo del Navigation Drawer',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
