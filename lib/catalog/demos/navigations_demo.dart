import 'package:flutter/material.dart';

class NavigationsDemo extends StatelessWidget {
  const NavigationsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // La parte de arriba de la app (barra con el título)
      appBar: AppBar(title: const Text('Demo: Navigation Drawer')),

      // Drawer = menú lateral que se abre desde el borde izquierdo
      drawer: Drawer(
        // Usamos material como surface(el fondo azul)
        child: Material(
          //creamos una lista de opciones dentro del drawer
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  'Cuidem Junts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              // Opción 1: Inicio
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                onTap: () => Navigator.pop(context), // Cierra el menú
              ),

              // Opción 2: Configuración
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () => Navigator.pop(context),
              ),

              // Opción 3: Acerca de
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Acerca de'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),

      // El cuerpo principal también está dentro de una surface
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Bienvenido a la demo del Navigation Drawer',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
