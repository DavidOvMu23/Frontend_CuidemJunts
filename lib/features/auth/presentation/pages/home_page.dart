import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';

class HomePage extends StatelessWidget {
  final void Function(bool) onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz de usuario
    return Scaffold(
      // AppBar con título y notificaciones
      appBar: AppBar(
        title: const Text('Preferencias de la app'),
        centerTitle: true,
        actions: [
          //Notificaciones
          Badge(
            label: const Text('10'),
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: Mostrar notificaciones de base de datos
              },
            ),
          ),
        ],
      ),

      // Menú lateral para navegar a Preferencias
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                'Cuidem Junts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // opción de preferencias
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Preferencias'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PreferencesPage(onToggleTheme: onToggleTheme),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Página principal')),
    );
  }
}
