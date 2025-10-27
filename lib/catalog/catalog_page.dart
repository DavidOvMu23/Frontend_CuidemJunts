import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/catalog/demos/buttons_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/textfields_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/communications_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/containers_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/navigations_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/selections_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/typography_demo.dart';

// -------- WIDGET PRINCIPAL DE LA PÁGINA --------
// CatalogPage es un StatefulWidget porque necesita recordar el modo oscuro o claro.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

// -------- ESTADO DE CatalogPage --------
// Esta clase guarda el estado de la página, como si está en modo claro u oscuro.
class _CatalogPageState extends State<CatalogPage> {
  // Variable para saber si el modo oscuro está activado
  bool isDark = false;

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  // Este método se llama cada vez que cambia algo en el estado (por ejemplo, al cambiar de tema)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuidem Junts',

      // Quita el cartel de "debug" que aparece en la esquina superior derecha
      debugShowCheckedModeBanner: false,

      // -------- CONFIGURACIÓN DE TEMAS --------
      // Se definen los temas claro y oscuro de la aplicación
      theme: AppTheme.lightTheme, // Tema claro
      darkTheme: AppTheme.darkTheme, // Tema oscuro
      // Aplica el tema según el valor de isDark
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // -------- CONTENIDO PRINCIPAL DE LA PÁGINA --------
      home: Builder(
        builder: (context) {
          return Scaffold(
            // -------- BARRA SUPERIOR (APPBAR) --------
            appBar: AppBar(
              title: const Text('Catálogo de Demos'),

              // Botón que permite cambiar entre modo claro y oscuro
              actions: [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => setState(() => isDark = !isDark),
                ),
              ],
            ),

            // -------- CUERPO PRINCIPAL --------
            body: Padding(
              padding: const EdgeInsets.all(16.0),

              // -------- PANEL PRINCIPAL (SURFACE) --------
              // Contiene la lista de demos con sus nombres y accesos
              child: Material(
                borderRadius: BorderRadius.circular(16), // Bordes redondeados
                // -------- LISTA DE OPCIONES --------
                child: ListView(
                  shrinkWrap: true, // El contenedor se adapta al contenido
                  // Cada elemento de la lista representa una demo distinta
                  children: [
                    // -------- DEMO: BUTTONS --------
                    ListTile(
                      title: const Text('Buttons'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ButtonsDemo(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // -------- DEMO: COMMUNICATIONS --------
                    ListTile(
                      title: const Text('Communications'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CommunicationsDemo(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // -------- DEMO: CONTAINERS --------
                    ListTile(
                      title: const Text('Containers'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ContainersDemo(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // -------- DEMO: NAVIGATIONS --------
                    ListTile(
                      title: const Text('Navigations'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NavigationsDemo(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // -------- DEMO: SELECTIONS --------
                    ListTile(
                      title: const Text('Selections'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SelectionsDemo(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // -------- DEMO: TEXT FIELDS --------
                    ListTile(
                      title: const Text('Text Fields'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TextFieldsDemo(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // -------- DEMO: TYPOGRAPHY --------
                    ListTile(
                      title: const Text('Typography'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TypographyDemo(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
