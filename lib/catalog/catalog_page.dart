import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_theme.dart';
import 'package:frontend_cuidemjunts/catalog/demos/buttons_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/text_fields_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/communications_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/containers_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/navigations_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/selections_demo.dart';
import 'package:frontend_cuidemjunts/catalog/demos/typography_demo.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  // Esta variable guarda si el modo oscuro está activado o no
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuidem Junts',
      debugShowCheckedModeBanner: false, //quitar puñetero cartel de debug
      // Definimos los temas de la app (claro y oscuro)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light, // cambia el modo

      home: Builder(
        builder: (context) {
          return Scaffold(
            // AppBar = barra superior de la pantalla
            appBar: AppBar(
              // La parte de arriba de la app (barra con el título)
              title: const Text('Catálogo de Demos'),
              // Botón para cambiar entre modo claro y oscuro
              actions: [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => setState(() => isDark = !isDark),
                ),
              ],
            ),

            // Cuerpo principal
            body: Padding(
              padding: const EdgeInsets.all(16.0),

              // SURFACE PRINCIPAL
              // Este es el panel donde se muestra la lista de demos
              child: Material(
                borderRadius: BorderRadius.circular(16), // bordes redondeados
                // La lista de opciones del catálogo
                child: ListView(
                  shrinkWrap: true, // el surface se adapta al contenido
                  children: [
                    // Cada ListTile es una opción que lleva a una demo
                    ListTile(
                      title: const Text('Buttons'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navega a la pantalla de ButtonsDemo
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ButtonsDemo(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1), // línea divisoria

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
