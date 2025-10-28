import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/catalog_page.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_containers_demo.dart';

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
              widget_listile_demo(
                icon: Icons.home,
                texto: 'Inicio',
                onTap: () => Navigator.pop,
              ),

              // -------- OPCIÓN 2: CONFIGURACIÓN --------
              widget_listile_demo(
                icon: Icons.settings,
                texto: 'Configuración',
                onTap: () => Navigator.pop,
              ),

              // -------- OPCIÓN 3: ACERCA DE --------
              widget_listile_demo(
                icon: Icons.info,
                texto: 'Acerca de',
                onTap: () => Navigator.pop,
              ),

              // -------- OPCIÓN 4: sali al menú --------
              widget_listile_demo(
                icon: Icons.exit_to_app,
                texto: 'Salir',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CatalogPage(), // Ir a la página del catálogo
                    ),
                  );
                },
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
