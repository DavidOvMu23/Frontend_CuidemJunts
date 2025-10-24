import 'package:flutter/material.dart';

// -------- WIDGET PRINCIPAL --------
// Esta clase muestra un ejemplo del uso del Navigation Drawer,
// que es el menú lateral que se abre desde el borde izquierdo de la pantalla.
class NavigationsDemo extends StatelessWidget {
  const NavigationsDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------- BARRA SUPERIOR (APPBAR) --------
      // Muestra el título de la pantalla
      appBar: AppBar(title: const Text('Demo: Navigation Drawer')),

      // -------- DRAWER (MENÚ LATERAL) --------
      // El Drawer es el panel que aparece al deslizar desde la izquierda
      drawer: Drawer(
        // Surface principal dentro del Drawer
        child: Material(
          // -------- LISTA DE OPCIONES --------
          // Contiene las diferentes secciones del menú lateral
          child: ListView(
            children: [
              // -------- ENCABEZADO DEL DRAWER --------
              // Normalmente muestra el nombre o logo de la app
              const DrawerHeader(
                child: Text(
                  'Cuidem Junts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              // -------- OPCIÓN 1: INICIO --------
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                // Al pulsar, se cierra el menú
                onTap: () => Navigator.pop(context),
              ),

              // -------- OPCIÓN 2: CONFIGURACIÓN --------
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () => Navigator.pop(context),
              ),

              // -------- OPCIÓN 3: ACERCA DE --------
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Acerca de'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),

      // -------- CUERPO PRINCIPAL --------
      // El contenido que se muestra cuando no se está usando el Drawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // -------- SURFACE PRINCIPAL --------
        child: Material(
          borderRadius: BorderRadius.circular(16), // Bordes redondeados

          child: const Padding(
            padding: EdgeInsets.all(16.0),

            // -------- CONTENIDO CENTRAL --------
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
